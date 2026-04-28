function PDBArray = writeFile(pdb_outname,segstruct_traj)

PDBArray = pdbwrite(pdb_outname,segstruct_traj);