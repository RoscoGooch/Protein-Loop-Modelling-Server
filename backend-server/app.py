from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import numpy as np
import matlab.engine
import os
from Bio.PDB import PDBParser, PPBuilder, PDBList, PDBIO, Select, NeighborSearch
import math

#configure matlab engine
eng = matlab.engine.start_matlab()
eng.cd(r'scripts', nargout=0)

#setup flask app
app = Flask(__name__)
CORS(app)

#configure folder to download pdb files into
DOWNLOAD_FOLDER = "PDB_files"
os.makedirs(DOWNLOAD_FOLDER, exist_ok=True)
app.config["DOWNLOAD_FOLDER"] = DOWNLOAD_FOLDER

@app.route('/setup-data', methods=['POST'])
def setup_data():
    #retrieve the pdb id desired
    iddata = request.get_json()
    open_pdb_id = (iddata['openPdbCode'])
    closed_pdb_id = (iddata['closedPdbCode'])

    #download the file using retrieve_pdb_file, then get protein structures from files
    try:
        open_pdb_filename = PDBList().retrieve_pdb_file(open_pdb_id, obsolete=False, pdir="PDB_files", file_format="pdb", overwrite=False)
        open_structure = PDBParser().get_structure("openProteinStructure", open_pdb_filename)
    except Exception:
        return jsonify({"error": "PDB File for open loop code not valid"}), 400
    try:
        closed_pdb_filename = PDBList().retrieve_pdb_file(closed_pdb_id, obsolete=False, pdir="PDB_files", file_format="pdb", overwrite=False)
        closed_structure = PDBParser().get_structure("closedProteinStructure", closed_pdb_filename)
    except Exception:
        return jsonify({"error": "PDB File for closed loop code not valid"}), 400

    #check that structures are not too big for the program to run efficiently
    open_atom_count = list(open_structure.get_atoms())
    closed_atom_count = list(closed_structure.get_atoms())

    #throw errors if structures too big
    if len(open_atom_count) > 10000:
        return jsonify({"error": "Open structure is too big"}), 400

    if len(closed_atom_count) > 10000:
        return jsonify({"error": "Closed structure is too big"}), 400

    #find all the chain ids in the structure
    list_of_open_chains = [chain.id for chain in open_structure.get_chains()]
    list_of_closed_chains = [chain.id for chain in closed_structure.get_chains()]
    return {
        "open_chains": list_of_open_chains,
        "closed_chains": list_of_closed_chains,

    }

@app.route('/retrieve-angles', methods=['POST'])
def retrieve_angles():
    #specify the structures you want to get angles from
    structure_details = request.get_json()
    segbeg = int((structure_details['segbeg']))
    segend = int((structure_details['segend']))
    open_chain = (structure_details['openChain'])
    closed_chain = (structure_details['closedChain'])
    open_pdb_id = (structure_details['openPdbCode'])
    closed_pdb_id = (structure_details['closedPdbCode'])

    # download the file using retrieve_pdb_file, then get protein structures from files
    try:
        open_pdb_filename = PDBList().retrieve_pdb_file(open_pdb_id, obsolete=False, pdir="PDB_files", file_format="pdb", overwrite=False)
        open_structure = PDBParser().get_structure("openProteinStructure", open_pdb_filename)[0][open_chain]
    except FileNotFoundError:
        return jsonify({"error": "PDB File for open code not valid"}), 400
    try:
        closed_pdb_filename = PDBList().retrieve_pdb_file(closed_pdb_id, obsolete=False, pdir="PDB_files", file_format="pdb", overwrite=False)
        closed_structure = PDBParser().get_structure("closedProteinStructure", closed_pdb_filename)[0][closed_chain]
    except FileNotFoundError:
        return jsonify({"error": "PDB File for closed code not valid"}), 400

    #get the phi and psi angles using tbe ppbuilder
    phi_angles = list()
    psi_angles = list()

    for pp in PPBuilder().build_peptides(closed_structure):
        phi_psi_list = pp.get_phi_psi_list()

        for phi, psi in phi_psi_list:
            if phi is None:
                phi_angles.append(None)
            else:
                phi_angles.append(math.degrees(phi))
            if psi is None:
                psi_angles.append(None)
            else:
                psi_angles.append(math.degrees(psi))

    phi_trimmed = phi_angles[segbeg:segend+1]
    psi_trimmed = psi_angles[segbeg:segend+1]

    return {
        "phi_angles": phi_trimmed,
        "psi_angles": psi_trimmed
    }

@app.route('/align-angles', methods=['POST'])
def align_angles():
    #retrieve necessary data from frontend
    structure_details = request.get_json()
    segbeg = int((structure_details['segbeg']))
    phi_angles = (structure_details["phi_angles"])
    psi_angles = (structure_details["psi_angles"])
    phi_angle_settings = (structure_details['phiAngleSettings'])
    psi_angle_settings = (structure_details['psiAngleSettings'])

    target_residues_phi = [
        [int(res), phi_angles[int(res) - segbeg - 1]]
        for res, val in phi_angle_settings.items()
        if val == "targeted"
    ]

    target_residues_psi = [
        [int(res), psi_angles[int(res) - segbeg - 1]]
        for res, val in psi_angle_settings.items()
        if val == "targeted"
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
    try:
        #Some phi, psi angles in the segment may be constrained but at least 7 need to be free. A trajectory in PDB format is output.

        #(see page 117 of notebook)
        #Retrieve necessary data from inputs
        data = request.get_json()

        chain = data.get("openChain")
        pdbcode = data.get("openPdbCode")
        segbeg = int(data.get("segbeg"))
        segend = int(data.get("segend"))

        target_residues_phi = np.array(data.get("target_residues_phi", []))
        target_residues_psi = np.array(data.get("target_residues_psi", []))
        constr_residues_phi = np.array(data.get("constr_residues_phi", []))
        constr_residues_psi = np.array(data.get("constr_residues_psi", []))

        #setup space to save data to
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
            return jsonify({"error": "No torsions are being targeted"}), 400
        if phi_intersect != 0:
            return jsonify({"error": "You are targeting and constraining the same phi torsion"}), 400
        if psi_intersect != 0:
            return jsonify({"error": "You are targeting and constraining the same psi torsion"}), 400

        #call Segment_prep
        packedsegstruct, natseg, nres, npep, nbond, ntors, nphipsi, n_notconstr, nfree, phipsi_index, phipsi_notconstr_index, tors_change_index, tors_change_target, constrset = eng.Segment_prep(pdbcode, chain, segbeg, segend, target_residues_phi, target_residues_psi, constr_residues_phi, constr_residues_psi, nargout=14)

        #stop if nfree is equal to or less than zero
        if nfree <= 0:
            return jsonify({"error": "Zero degrees of freedom, cannot target"}), 400

        #determine internal coordinates
        xn, yn, zn, xca, yca, zca, xc, yc, zc, xo, yo, zo, nside, xside, yside, zside, atlistN, atlistCA, atlistC, atlistO, atlist_side, lengs, angs, tors_initial = eng.PDBStruct_to_Internal_func2(nres, packedsegstruct, nargout=24)
        #set target torsion angles

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
    except Exception as e:
        return jsonify({"error": "Something went wrong with the calculations: " + str(e)}), 500

@app.route('/collision-check', methods=['GET'])
def collision_check():
    path = "scripts/LADH_loop_movement.pdb"
    structure = PDBParser().get_structure("collisionModel", path)
    radius = 1.6
    collisions = []
    for model in structure:
        atoms = list(model.get_atoms())
        ns = NeighborSearch(atoms)
        for atom1, atom2 in ns.search_all(radius, level='A'):
            res1 = atom1.get_parent()
            res2 = atom2.get_parent()

            #discard collisions where the parent residues are the same, and those where the residues are adjacent
            if abs(res1.get_id()[1] - res2.get_id()[1]) > 1:
                distance = atom1 - atom2

                collisions.append({
                    "model": model.id,
                    "res1": res1.get_id()[1],
                    "res2": res2.get_id()[1],
                    "distance": float(distance)
                })

    return jsonify({"collisions": collisions})


@app.route('/get-pdb-file', methods=['GET'])
def get_pdb_file():
    path = "scripts/LADH_loop_movement.pdb"
    return send_file(path, as_attachment=True)

@app.route('/get-model-startend', methods=['GET'])
def get_model_startend():
    path = "scripts/LADH_loop_movement.pdb"

    start_phi_angles = list()
    start_psi_angles = list()
    end_phi_angles = list()
    end_psi_angles = list()

    #get models from the data structure
    structure = PDBParser().get_structure("finalItem", path)
    models = list(structure.get_models())

    #get first and last model from the model set, then create them as classes with PPBuilder
    first_model = PPBuilder().build_peptides(models[0])
    last_model = PPBuilder().build_peptides(models[-1])

    #get the phi and psi angles from the models
    for pp in first_model:
        phi_psi_list = pp.get_phi_psi_list()

        for phi, psi in phi_psi_list:
            if phi is None:
                start_phi_angles.append(None)
            else:
                start_phi_angles.append(math.degrees(phi))
            if psi is None:
                start_psi_angles.append(None)
            else:
                start_psi_angles.append(math.degrees(psi))

    for pp in last_model:
        phi_psi_list = pp.get_phi_psi_list()

        for phi, psi in phi_psi_list:
            if phi is None:
                end_phi_angles.append(None)
            else:
                end_phi_angles.append(math.degrees(phi))
            if psi is None:
                end_psi_angles.append(None)
            else:
                end_psi_angles.append(math.degrees(psi))

    return {
        "start_model_phi_angles": start_phi_angles,
        "start_model_psi_angles": start_psi_angles,
        "end_model_phi_angles": end_phi_angles,
        "end_model_psi_angles": end_psi_angles
    }