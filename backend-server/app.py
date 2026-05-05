from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import numpy as np
import matlab.engine
import os
from Bio.PDB.ic_rebuild import write_PDB
from Bio.PDB import PDBParser, PPBuilder, PDBList, PDBIO, Select
import Bio.PDB
import math

eng = matlab.engine.start_matlab()
eng.cd(r'scripts', nargout=0)

app = Flask(__name__)
CORS(app)

DOWNLOAD_FOLDER = "PDB_files"
os.makedirs(DOWNLOAD_FOLDER, exist_ok=True)
app.config["DOWNLOAD_FOLDER"] = DOWNLOAD_FOLDER

@app.route('/setup-data', methods=['POST'])
def setup_data():
    # Create an instance of the PDBList class
    pdb_list = PDBList()
    # Specify the PDB ID of the structure you want to download
    iddata = request.get_json()
    start_pdb_id = (iddata['pdbcode'])
    # Download the file using the retrieve_pdb_file method
    pdb_filename = pdb_list.retrieve_pdb_file(start_pdb_id, pdir="PDB_files", file_format="pdb")
    #get file
    structure = PDBParser().get_structure("downloads", pdb_filename)
    #find all the chains in the structure
    list_of_chains = [chain.id for chain in structure.get_chains()]
    return {
        "start_pdb_id": start_pdb_id,
        "chains": list_of_chains
    }

@app.route('/retrieve-angles', methods=['POST'])
def retrieve_angles():
    #create an instance of the PDBList class
    pdb_list = PDBList()
    #specify the structures you want to get angles from
    structure_details = request.get_json()
    segbeg = int((structure_details['segbeg']))
    segend = int((structure_details['segend']))
    end_pdb_id = (structure_details['pdbcode_end'])
    chain = (structure_details['start_chain'])
    #download the file using the retrieve_pdb_file method
    end_pdb_filename = pdb_list.retrieve_pdb_file(end_pdb_id, pdir="PDB_files", file_format="pdb")
    end_structure = PDBParser().get_structure("downloads", end_pdb_filename)[0][chain]
    #get the phi and psi angles using tbe ppbuilder
    ppb = PPBuilder()
    phi_map = {}
    psi_map = {}

    for pp in ppb.build_peptides(end_structure):
        for residue, (phi, psi) in zip(pp, pp.get_phi_psi_list()):
            res_id = residue.get_id()[1]
            phi_map[res_id] = None if phi is None else math.degrees(phi)
            psi_map[res_id] = None if psi is None else math.degrees(psi)

    phi_trimmed = {
        res: angle
        for res, angle in phi_map.items()
        if segbeg <= res <= segend
    }

    psi_trimmed = {
        res: angle
        for res, angle in psi_map.items()
        if segbeg <= res <= segend
    }


    return {
        "phi_angles": phi_trimmed,
        "psi_angles": psi_trimmed
    }

@app.route('/align-angles', methods=['POST'])
def align_angles():
    structure_details = request.get_json()
    phi_map = (structure_details["phi_angles"])
    psi_map = (structure_details["psi_angles"])
    phi_angle_settings = (structure_details['phi_angle_settings'])
    psi_angle_settings = (structure_details['psi_angle_settings'])

    phi_targets = [
        int(res) for res, val in phi_angle_settings.items()
        if val == "targeted"
    ]

    psi_targets = [
        int(res) for res, val in psi_angle_settings.items()
        if val == "targeted"
    ]

    target_residues_phi = [
        [res, phi_map[str(res)]]
        for res in phi_targets
        if str(res) in phi_map and phi_map[str(res)] is not None
    ]

    target_residues_psi = [
        [res, psi_map[str(res)]]
        for res in psi_targets
        if str(res) in psi_map and psi_map[str(res)] is not None
    ]

    constr_residues_phi = [
        int(res) for res, val in phi_angle_settings.items()
        if val == "constrained"
    ]

    constr_residues_psi = [
        int(res) for res, val in psi_angle_settings.items()
        if val == "constrained"
    ]

    return jsonify({
        "target_residues_phi": target_residues_phi,
        "target_residues_psi": target_residues_psi,
        "constr_residues_phi": constr_residues_phi,
        "constr_residues_psi": constr_residues_psi
    })


@app.route("/")
def home():
    return "<p>Backend server</p>"

@app.route('/update-angles', methods=['POST'])
def update_angles():
    #Reads in PDB structure determines the phi, psi angles and the bond angles and omega torsions angles(The latter two are kept fixed).
    #A segment is selected as are target phi, psi angles for this segment.
    #The aim is to get as close to these target phi, psi as possible retaining the fixed end groups.
    #Some phi, psi angles in the segment may be constrained but at least 7 need to be free. A trajectory in PDB format is output.

    #(see page 117 of notebook)
    #Read in protein structure and select segment and residues to change and constrain tic.
    data = request.get_json()

    chain = data.get("start_chain")
    pdbcode = data.get("pdbcode")
    segbeg = int(data.get("segbeg"))
    segend = int(data.get("segend"))

    target_residues_phi = np.array(data.get("target_residues_phi", []))
    target_residues_psi = np.array(data.get("target_residues_psi", []))
    constr_residues_phi = np.array(data.get("constr_residues_phi", []))
    constr_residues_psi = np.array(data.get("constr_residues_psi", []))

    import os

    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    SCRIPTS_DIR = os.path.join(BASE_DIR, "scripts")
    os.makedirs(SCRIPTS_DIR, exist_ok=True)

    pdb_outname = os.path.join(SCRIPTS_DIR, "LADH_loop_movement.pdb")

    #specify number of iterations
    n_iter = 10000

    #Do some checking

    #check not constraining and targeting same torsions
    phi_intersect = 0
    psi_intersect = 0
    if target_residues_phi.size > 0:
        phi_intersect = len(np.intersect1d(constr_residues_phi, target_residues_phi[:, 0]))
    if target_residues_psi.size > 0:
        psi_intersect = len(np.intersect1d(constr_residues_psi, target_residues_psi[:, 0]))
    if target_residues_phi.size == 0 and target_residues_psi.size == 0:
        return jsonify({"error": "no torsions are being targeted"})
    if phi_intersect != 0:
        return jsonify({"error": "you are targeting and constraining the same phi torsion"})
    if psi_intersect != 0:
        return jsonify({"error": "you are targeting and constraining the same psi torsion"})

    #call Segment_prep
    packedsegstruct, natseg, nres, npep, nbond, ntors, nphipsi, n_notconstr, nfree, phipsi_index, phipsi_notconstr_index, tors_change_index, tors_change_target, constrset = eng.Segment_prep(pdbcode, chain, segbeg, segend, target_residues_phi, target_residues_psi, constr_residues_phi, constr_residues_psi, nargout=14)

    #stop if nfree is equal to or less than zero
    if nfree <= 0:
        return jsonify({"error": "zero degrees of freedom, cannot target"})

    #Determine internal coordinates
    xn, yn, zn, xca, yca, zca, xc, yc, zc, xo, yo, zo, nside, xside, yside, zside, atlistN, atlistCA, atlistC, atlistO, atlist_side, lengs, angs, tors_initial = eng.PDBStruct_to_Internal_func2(nres, packedsegstruct, nargout=24)
    #Set target torsion angles

    #set target phi and psi angles at their initial values
    #tors_target = tors_initial;
    tors_target = np.zeros((int(ntors), 1))
    #set target values
    change_as_array = np.array(tors_change_index).astype(int) - 1
    values = np.array(tors_change_target).flatten()
    tors_target[change_as_array, 0] = values[change_as_array]

    #tors_target_mask is used to mask torsions that are not targeted
    tors_target_mask = np.zeros((int(ntors), 1))
    tors_target_mask[change_as_array, 0] = 1.0

    #Do targeting and get the torsions trajectory
    n_iterstop, torstraj, tors_final, rmsd_initial, normlamda, delta_targ_final, distfinal = eng.Loop_Target_func2(n_iter, lengs, angs, constrset, npep, nbond, nphipsi, phipsi_notconstr_index, n_notconstr, nfree, tors_initial, tors_target_mask, tors_target, nargout=7)

    flat_index = np.array(phipsi_index).astype(int).flatten() - 1
    delta_phipsi = np.array(delta_targ_final)[flat_index]

    #data = [[tors_initial(phipsi_index)], [tors_final(phipsi_index)], [tors_target(phipsi_index)], [delta_phipsi]]
    #trajectory = np.array[data]
    distfinal

    #Use interpolation on trajectory for output
    nmod, torsmod = eng.interpol_torstraj_func2(n_iterstop, npep, nphipsi, phipsi_index, tors_initial, tors_final, torstraj, nargout=2)

    #Convert to Cartesian coordinate trajectory

    #this function will produce side chain coordinates as well
    traj_output = eng.Make_PDBstruct_Tortraj_func(nmod, natseg, nres, packedsegstruct, xn, yn, zn, xca, yca, zca, xc, yc, zc, xo, yo, zo, nside, xside, yside, zside, atlistN, atlistCA, atlistC, atlistO, atlist_side, lengs, angs, tors_initial, torsmod, pdb_outname)

    return send_file(pdb_outname, mimetype="chemical/x-pdb")

@app.route('/get-pdb-file', methods=['POST'])
def get_pdb_file():
    path = "scripts/LADH_loop_movement.pdb"
    return send_file(path, as_attachment=True)

@app.route('/get-model-startend', methods=['POST'])
def get_model_startend():
    path = "scripts/LADH_loop_movement.pdb"

    start_phi_angles = list()
    start_psi_angles = list()
    end_phi_angles = list()
    end_psi_angles = list()

    structure = PDBParser().get_structure("finalitem", path)
    models = list(structure.get_models())
    last_model = models[-1]
    first_model = models[0]

    ppb = PPBuilder()
    last_model = ppb.build_peptides(last_model)
    first_model = ppb.build_peptides(first_model)

    for pp in first_model:
        phi_psi_list = pp.get_phi_psi_list()

        for phi, psi in phi_psi_list:
            start_phi_angles.append(None if phi is None else math.degrees(phi))
            start_psi_angles.append(None if psi is None else math.degrees(psi))

    for pp in last_model:
        phi_psi_list = pp.get_phi_psi_list()

        for phi, psi in phi_psi_list:
            end_phi_angles.append(None if phi is None else math.degrees(phi))
            end_psi_angles.append(None if psi is None else math.degrees(psi))

    return {
        "start_model_phi_angles": start_phi_angles,
        "start_model_psi_angles": start_psi_angles,
        "end_model_phi_angles": end_phi_angles,
        "end_model_psi_angles": end_psi_angles
    }