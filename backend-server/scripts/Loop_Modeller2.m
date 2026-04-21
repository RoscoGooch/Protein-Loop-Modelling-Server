%% Loop_Modeller2

% Reads in PDB structure determines the phi,psi angles and the bond 
% angles and omega torsions angles (The latter two are kept fixed).
% A segment is selected as are target phi,psi angles for this segment. 
% The aim is to get as close to these target phi,psi 
% as possible retaining the fixed end groups.
% Some phi,psi angles in the segment may be constrained but at least
% 7 need to be free. A trajectory in PDB format is output.

% (see page 117 of notebook) 
%% Read in protein structure and select segment and residues to change and constrain
tic

% ALCOHOL DEHYDROGENASE
pdbcode='1adg';
pdb_outname='LADH_loopmovement.pdb';
chain='A'

segbeg=290;
segend=301;
% in format [resnum1 phi1; resnum2 phi2; ..]
target_residues_phi=[291 -90; 292 -110; 293 -64; 294 -90];
target_residues_psi=[291 122; 292 -35; 293 147];
%in format [resnum1 resnum2 ...]
constr_residues_phi=[295 296];
constr_residues_psi=[294 295];
%constr_residues_phi=[];
%constr_residues_psi=[];

% specifiy number of iternations
n_iter=10000;

%% Do some checking

% check not constraining and targeting same torsions
phi_intersect=0;
psi_intersect=0;
if ~isempty(target_residues_phi) 
    phi_intersect=length(intersect(constr_residues_phi,target_residues_phi(:,1)));
end
if ~isempty(target_residues_psi)
    psi_intersect=length(intersect(constr_residues_psi,target_residues_psi(:,1)));
end
if isempty(target_residues_phi) && isempty(target_residues_psi) 
    'no torsions are being targeted'
    return
end
if phi_intersect ~= 0
    'you are targeting and constraining the same phi torsion'
    intersect(constr_residues_phi,target_residues_phi(:,1))
    return
end
if psi_intersect ~= 0
    'you are targeting and constraining the same psi torsion'
    intersect(constr_residues_psi,target_residues_psi(:,1))
    return
end

% call Segment_prep
[segstruct,natseg,nres,npep,nbond,ntors,nphipsi,n_notconstr,nfree,phipsi_index,phipsi_notconstr_index,tors_change_index,tors_change_target,constrset]=Segment_prep(pdbcode,chain,segbeg,segend,target_residues_phi,target_residues_psi,constr_residues_phi,constr_residues_psi);

% stop if nfree is equal to or less than zero
if nfree <= 0
    'zero degrees of freedom, cannot target'
    return
end
%% Determine internal coordinates

[xn,yn,zn,xca,yca,zca,xc,yc,zc,xo,yo,zo,nside,xside,yside,zside,atlistN,atlistCA,atlistC,atlistO,atlist_side,lengs,angs,tors_initial]=PDBStruct_to_Internal_func2(nres,segstruct);

%% Set target torsion angles

%set target phi and psi angles at their initial values
%tors_target=tors_initial;
tors_target=zeros(ntors,1);
% set target values
tors_target(tors_change_index)=tors_change_target(tors_change_index)

% tors_target_mask is used to mask torsions that are not targeted
tors_target_mask=zeros(ntors,1);
tors_target_mask(tors_change_index)=1.0;

%% Do targeting and get the torsions trajectory

[n_iterstop,torstraj,tors_final,rmsd_initial,normlamda,delta_targ_final,distfinal]=Loop_Target_func2(n_iter,lengs,angs,constrset,npep,nbond,nphipsi,phipsi_notconstr_index,n_notconstr,nfree,tors_initial,tors_target_mask,tors_target);

delta_phipsi=delta_targ_final(phipsi_index);

[tors_initial(phipsi_index) tors_final(phipsi_index) tors_target(phipsi_index) delta_phipsi]
distfinal

%% Use interpolation on trajectory for output

[nmod,torsmod]=interpol_torstraj_func2(n_iterstop,npep,nphipsi,phipsi_index,tors_initial,tors_final,torstraj);

%% Convert to Cartesian coordinate trajectory

%this function will produce side chain coordinates as well
[segstruct_traj]=Make_PDBstruct_Tortraj_func(nmod,natseg,nres,segstruct,xn,yn,zn,xca,yca,zca,xc,yc,zc,xo,yo,zo,nside,xside,yside,zside,atlistN,atlistCA,atlistC,atlistO,atlist_side,lengs,angs,tors_initial,torsmod);

%% Output structure trajectory

pdbwrite(pdb_outname,segstruct_traj);
