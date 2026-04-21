%% Segment_prep

% Prepares the segment. It reads the pdb file into a structure and selects
% the residues in the segment and creates arrays for conversion between residues,
% and phi or psi indexing and torsion indexing which includes omegas

function [segstruct,natseg,nres,npep,nbond,ntors,nphipsi,n_notconstr,nfree,phipsi_index,phipsi_notconstr_index,tors_change_index,tors_change_target,constrset]=Segment_prep(pdbcode,chain,segbeg,segend,target_residues_phi,target_residues_psi,constr_residues_phi,constr_residues_psi)

% Get PDB file
Protein=getpdb(pdbcode);
%pdbwrite([pdbcode '.pdb'],Protein);
%Protein=pdbread([pdbcode '.pdb']);


% Create structure for segment
seglen=segend-segbeg+1;
natom=size(Protein.Model(1).Atom,2);
iatseg=0;
ires=0;
resbef=-1000;
for iat=1:natom
    if strcmp(Protein.Model(1).Atom(iat).chainID,chain) && (segbeg <= Protein.Model(1).Atom(iat).resSeq && Protein.Model(1).Atom(iat).resSeq  <= segend)
        if Protein.Model(1).Atom(iat).resSeq ~= resbef
            ires=ires+1;
            resbef=Protein.Model(1).Atom(iat).resSeq;
        end
        iatseg=iatseg+1;
        Protein.Model(1).Atom(iat).resSeq
        segstruct.Model(1).Atom(iatseg)=Protein.Model(1).Atom(iat);
    end
end

nres=ires;
natseg=iatseg;

if nres ~= seglen
    'error, there may be a break in chain'
    return
end

% determine indexing conversions
npep=nres-1;
nbond=npep*3;
[phi_index]=phi_bonds(npep);
[psi_index]=psi_bonds(npep);
phipsi_index=union(phi_index,psi_index);
nphipsi=length(phipsi_index);
ntors=nphipsi+npep;

% following gives phi psi index as you count them from torsions as you count them
tors_to_phipsi=tors_to_phipsi_func(npep);



% determine array that given a phi or psi of a set of residues specifies the torsion index
iphipsi=0;
% phi_or_psi indicates phi or psi, 1 being phi and 2 psi
phi_or_psi=2;
for irespdb=segbeg:segend
    iphipsi=iphipsi+1;
    res_to_tor(irespdb,phi_or_psi)=phipsi_index(iphipsi);
    if phi_or_psi == 2
        phi_or_psi=1;
    elseif phi_or_psi == 1
        phi_or_psi=2;
    end
    if irespdb == segbeg  || irespdb == segend
        continue
    end   
    iphipsi=iphipsi+1;
    res_to_tor(irespdb,phi_or_psi)=phipsi_index(iphipsi);
    if phi_or_psi == 2
        phi_or_psi=1;
    elseif phi_or_psi == 1
        phi_or_psi=2;
    end
end

% determine torsion indices for selected phi psi angles and their target values
tarphi=true;
if size(target_residues_phi,1) == 0 && size(target_residues_phi,2) == 0
    tarphi=false;
end
tarpsi=true;
if size(target_residues_psi,1) == 0 && size(target_residues_psi,2) == 0
    tarpsi=false;
end
if tarphi && tarpsi   
    tors_change_index=[res_to_tor(target_residues_phi(:,1),1);res_to_tor(target_residues_psi(:,1),2)];
    tors_change_target(tors_change_index)=[target_residues_phi(:,2);target_residues_psi(:,2)];
elseif tarphi
    tors_change_index=[res_to_tor(target_residues_phi(:,1),1)];
    tors_change_target(tors_change_index)=[target_residues_phi(:,2)];  
elseif tarpsi
    tors_change_index=[res_to_tor(target_residues_psi(:,1),2)];
    tors_change_target(tors_change_index)=[target_residues_psi(:,2)];
end
% determine phi psi indices for constrained torsions
tors_constr_index=[res_to_tor(constr_residues_phi,1);res_to_tor(constr_residues_psi,2)];
constrset=sort(tors_to_phipsi(tors_constr_index));

% determine number of degrees of freedom
phipsi_notconstr_index=phipsi_index;
phipsi_notconstr_index(constrset)=[];
n_notconstr=nphipsi-length(constrset);
nfree=n_notconstr-6;