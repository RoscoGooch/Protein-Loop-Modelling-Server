from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import numpy as np
import matlab.engine
import os
from Bio.PDB.ic_rebuild import write_PDB
from Bio.PDB import PDBParser, PPBuilder, PDBList
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
    pdb_id = (iddata['pdbcode'])
    # Download the file using the retrieve_pdb_file method
    pdb_filename = pdb_list.retrieve_pdb_file(pdb_id, pdir="PDB_files", file_format="pdb")
    structure = PDBParser().get_structure("downloads", pdb_filename)
    list_of_chains = [chain.id for chain in structure.get_chains()]
    return {
        "pdb_id": pdb_id,
        "chains": list_of_chains
    }

@app.route('/retrieve-angles', methods=['POST'])
def retrieve_angles():
    # Create an instance of the PDBList class
    pdb_list = PDBList()
    # Specify the structures you want to get angles from
    structure_details = request.get_json()
    end_pdb_id = (structure_details['pdbcode_end'])
    segbeg = int((structure_details['segbeg']))
    segend = int((structure_details['segend']))
    chain = (structure_details['start_chain'])
    # Download the file using the retrieve_pdb_file method
    end_pdb_filename = pdb_list.retrieve_pdb_file(end_pdb_id, pdir="PDB_files", file_format="pdb")
    end_structure = PDBParser().get_structure("downloads", end_pdb_filename)[0][chain]
    phi_angles = list()
    psi_angles = list()
    ppb = PPBuilder()
    for pp in ppb.build_peptides(end_structure):
        phi_psi = pp.get_phi_psi_list()[segbeg:segend]
        for i, (phi, psi) in enumerate(phi_psi):
            this_phi_angle = None if phi is None else math.degrees(phi)
            this_psi_angle = None if psi is None else math.degrees(psi)
            phi_angles.append(this_phi_angle)
            psi_angles.append(this_psi_angle)
    return {
        "phi_angles": psi_angles,
        "psi_angles": psi_angles
    }

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
    chain = 'A'
    pdbcode = '1adg'
    pdb_outname = 'LADH_loop_movement.pdb'

    segbeg = 290
    segend = 301

    angledata = request.get_json()

    # in format[resnum1 phi1; resnum2   phi2;..]
    #target_phi_data = np.array([[angledata['phiAngleTX1'], angledata['phiAngleTY1']], [angledata['phiAngleTX2'], angledata['phiAngleTY2']], [angledata['phiAngleTX3'], angledata['phiAngleTY3']], [angledata['phiAngleTX4'], angledata['phiAngleTY4']]], dtype=np.float64)
    #target_psi_data = np.array([[angledata['psiAngleTX1'], angledata['psiAngleTY1']], [angledata['psiAngleTX2'], angledata['psiAngleTY2']], [angledata['psiAngleTX3'], angledata['psiAngleTY3']], [angledata['phiAngleTX4'], angledata['phiAngleTY4']]], dtype=np.float64)
    # in format[resnum1 resnum2...]
    #constr_phi_data = np.array([angledata['phiAngleC1'], angledata['phiAngleC2']], dtype=np.float64)
    #constr_psi_data = np.array([angledata['psiAngleC1'], angledata['psiAngleC2']], dtype=np.float64)

    #remove values that are 0

    #target_residues_phi = target_phi_data[~np.all(target_phi_data == 0, axis=1)]
    #target_residues_psi = target_psi_data[~np.all(target_psi_data == 0, axis=1)]

    #constr_residues_phi = np.delete(constr_phi_data, np.where(constr_phi_data == 0))
    #constr_residues_psi = np.delete(constr_psi_data, np.where(constr_psi_data == 0))

    # constr_residues_phi = [];
    target_residues_phi = np.array([[291, -90], [292, -110], [293, -64], [294, -90]])
    target_residues_psi = np.array([[291, 122], [292, -35], [293, 147]])
    constr_residues_phi = np.array([295, 296])
    constr_residues_psi = np.array([294, 295])
    # constr_residues_psi = [];


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

    path = "scripts/LADH_loop_movement.pdb"
    return send_file(path, as_attachment=True)

@app.route('/get-pdb-file', methods=['POST'])
def get_pdb_file():
    path = "scripts/LADH_loop_movement.pdb"
    return send_file(path, as_attachment=True)