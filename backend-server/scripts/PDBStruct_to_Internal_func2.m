%% PDBStruct_to_Internal_func2

% Given a PDB struct and chain identifier it calculates bond angles and torsions

function [xn,yn,zn,xca,yca,zca,xc,yc,zc,xo,yo,zo,nside,xside,yside,zside,atlistN,atlistCA,atlistC,atlistO,atlist_side,lengs,angs,tors]=PDBStruct_to_Internal_func2(nres,segstruct)

%% determine backbone atoms

[skip,respdb,xn,yn,zn,xca,yca,zca,xc,yc,zc,xo,yo,zo,nside,xside,yside,zside,atlistN,atlistCA,atlistC,atlistO,atlist_side]=N_CA_C_fromPDB_func2(nres,segstruct);

if skip
    return;
end

%% now determine all torsion angles

[phi,psi,omega]=PhiPsiOmega_from_bbatoms_func(nres,xn,yn,zn,xca,yca,zca,xc,yc,zc);
ibond=0;
iang=0;
itor=0;

ntors=0;

respdbbond=zeros(nres*3-3,1);
respdbang=zeros(nres*3-3,1);
respdbtor=zeros(nres*3-3,1);

lengs=zeros(nres*3-3,1);
angs=zeros(nres*3-3,1);
tors=zeros(nres*3-3,1);


% below omega torsion is assigned to residue before
for ires=1:nres-1
    itor=itor+1;
    tors(itor)=psi(ires);
    respdbtor(itor)=respdb(ires);
    itor=itor+1;
    tors(itor)=omega(ires);
    respdbtor(itor)=respdb(ires);
    itor=itor+1;
    tors(itor)=phi(ires+1);
    respdbtor(itor)=respdb(ires+1);
end
ntors=itor;

%% now determine all bond angles

[n_ang,ca_ang,c_ang]=BondAngles_from_bbatoms_func(nres,xn,yn,zn,xca,yca,zca,xc,yc,zc);

for ires=1:nres-1
    iang=iang+1;
    angs(iang)=c_ang(ires);
    respdbang(iang)=respdb(ires);
    iang=iang+1;
    angs(iang)=n_ang(ires+1);
    respdbang(iang)=respdb(ires);
    iang=iang+1;
    angs(iang)=ca_ang(ires+1);
    respdbang(iang)=respdb(ires+1);
end

%% now determine all bond lengths

[nca,cac,cn]=BondLengths_from_bbatoms_func(nres,xn,yn,zn,xca,yca,zca,xc,yc,zc)

% below C-N bond is assigned to residue before
for ires=1:nres-1
    ibond=ibond+1;
    lengs(ibond)=cac(ires)
    respdbbond(ibond)=respdb(ires);
    ibond=ibond+1;
    lengs(ibond)=cn(ires);
    respdbbond(ibond)=respdb(ires);
    ibond=ibond+1;
    lengs(ibond)=nca(ires+1);
    respdbbond(ibond)=respdb(ires+1);
end


