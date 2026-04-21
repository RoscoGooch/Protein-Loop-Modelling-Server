from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import matlab.engine
from Bio.PDB.ic_rebuild import write_PDB

eng = matlab.engine.start_matlab()
eng.cd(r'scripts', nargout=0)

app = Flask(__name__)
CORS(app)

pdbcode = ''
pdb_outname = ''
chain = ''

segbeg = 0
segend = 1

def get_pdbcode():
    return pdbcode

def get_pdb_outname():
    return pdb_outname

def get_chain():
    return chain

def get_segbeg():
    return segbeg

def get_segend():
    return segend

def set_pdb_structure(thiscode, thisfile, thischain):
    pdbcode = thiscode
    pdb_outname = thisfile
    chain = thischain

def set_segbeg_segend(thisbeg, thisend):
    segbeg = thisbeg
    segend = thisend

@app.route("/")
def home():
    return "<p>Backend server</p>"

@app.route('/load-model', methods=['POST'])
def load_model():
    #read model file
    #look for relevant info
    # ALCOHOL DEHYDROGENASE
    data = request.get_json()
    print(data)
    set_pdb_structure(data['pdbcode'], 'LADH_loop_movement.pdb', data['chain'])
    set_segbeg_segend(data['segbeg'], data['segend'])

    #test info works, then return model
    valid = True
    if valid == True:
        return [data['pdbcode'], data['chain'], data['segbeg'], data['segend']]
    else:
        return "Error"

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

    # in format[resnum1 phi1; resnum2   phi2;..]
    target_residues_phi = np.array([[291, -90], [292, -110], [293, -64], [294, -90]])
    target_residues_psi = np.array([[291, 122], [292, -35], [293, 147]])
    # in format[resnum1 resnum2...]
    constr_residues_phi = np.array([295, 296])
    constr_residues_psi = np.array([294, 295])
    # constr_residues_phi = [];
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
        return 'no torsions are being targeted'
    if phi_intersect != 0:
        return 'you are targeting and constraining the same phi torsion' + str(constr_residues_phi & target_residues_phi[:, 0])
    if psi_intersect != 0:
        return 'you are targeting and constraining the same psi torsion' + str(constr_residues_psi & target_residues_psi[:, 0])

    #call Segment_prep
    [segstruct, natseg, nres, npep, nbond, ntors, nphipsi, n_notconstr, nfree, phipsi_index, phipsi_notconstr_index, tors_change_index, tors_change_target, constrset] = eng.Segment_prep(pdbcode, chain, segbeg, segend, target_residues_phi, target_residues_psi, constr_residues_phi, constr_residues_psi)

    #stop if nfree is equal to or less than zero
    if nfree <= 0:
        return 'zero degrees of freedom, cannot target'

    #Determine internal coordinates
    [xn, yn, zn, xca, yca, zca, xc, yc, zc, xo, yo, zo, nside, xside, yside, zside, atlistN, atlistCA, atlistC, atlistO, atlist_side, lengs, angs, tors_initial] = eng.PDBStruct_to_Internal_func2(nres, segstruct)
    #Set target torsion angles

    #set target phi and psi angles at their initial values
    #tors_target = tors_initial;
    tors_target = np.zeros(ntors, 1)
    #set target values
    tors_target[tors_change_index] = tors_change_target(tors_change_index)

    #tors_target_mask is used to mask torsions that are not targeted
    tors_target_mask = np.zeros(ntors, 1)
    tors_target_mask[tors_change_index] = 1.0

    #Do targeting and get the torsions trajectory
    [n_iterstop, torstraj, tors_final, rmsd_initial, normlamda, delta_targ_final, distfinal] = eng.Loop_Target_func2(n_iter, lengs, angs, constrset, npep, nbond, nphipsi, phipsi_notconstr_index, n_notconstr, nfree, tors_initial, tors_target_mask, tors_target)

    delta_phipsi = delta_targ_final(phipsi_index)

    #Use interpolation on trajectory for output
    [nmod, torsmod] = eng.interpol_torstraj_func2(n_iterstop, npep, nphipsi, phipsi_index, tors_initial, tors_final, torstraj)

    #Convert to Cartesian coordinate trajectory

    #this function will produce side chain coordinates as well
    [segstruct_traj] = eng.Make_PDBstruct_Tortraj_func(nmod, natseg, nres, segstruct, xn, yn, zn, xca, yca, zca, xc, yc, zc, xo, yo, zo, nside, xside, yside, zside, atlistN, atlistCA, atlistC, atlistO, atlist_side, lengs, angs, tors_initial, torsmod)

    #Output structure trajectory
    write_PDB(segstruct_traj, pdb_outname)

    #torsarray = [tors_initial(phipsi_index) tors_final(phipsi_index) tors_target(phipsi_index) delta_phipsi]
    return distfinal