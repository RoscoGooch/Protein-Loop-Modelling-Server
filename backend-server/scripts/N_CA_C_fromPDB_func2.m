%% N_CA_C_fromPDB_func2

% Reads  N C-alpha and C coordinates from PDB structure


function [skip,respdb,xn,yn,zn,xca,yca,zca,xc,yc,zc,xo,yo,zo,nside,xside,yside,zside,atlistN,atlistCA,atlistC,atlistO,atlist_side]=N_CA_C_fromPDB_func2(nres,pdbstructure)

%% read a PDB file using bioinformatics toolbox and put coords of N,CA and C atoms into arrays.

natom=length(pdbstructure.Model.Atom);
N_ires=0;
CA_ires=0;
C_ires=0;
O_ires=0;
iatside=0;
skip=false;
nsideatomsmax=40;
respdb=zeros(1,nres);
xn=zeros(1,nres);
yn=zeros(1,nres);
zn=zeros(1,nres);
xca=zeros(1,nres);
yca=zeros(1,nres);
zca=zeros(1,nres);
xc=zeros(1,nres);
yc=zeros(1,nres);
zc=zeros(1,nres);
nside=zeros(1,nres);
atlist_side=zeros(nsideatomsmax,nres);
xside=zeros(nsideatomsmax,nres);
yside=zeros(nsideatomsmax,nres);
zside=zeros(nsideatomsmax,nres);
for iatm=1:natom
    if strcmp(pdbstructure.Model(1).Atom(iatm).AtomName,'N')
        N_ires=N_ires+1;
        atlistN(N_ires)=iatm;
        respdb(N_ires)=pdbstructure.Model(1).Atom(iatm).resSeq;
        xn(N_ires)=pdbstructure.Model(1).Atom(iatm).X;
        yn(N_ires)=pdbstructure.Model(1).Atom(iatm).Y;
        zn(N_ires)=pdbstructure.Model(1).Atom(iatm).Z;
    elseif strcmp(pdbstructure.Model(1).Atom(iatm).AtomName,'CA') 
        CA_ires=CA_ires+1;
        atlistCA(CA_ires)=iatm;
        xca(CA_ires)=pdbstructure.Model(1).Atom(iatm).X;
        yca(CA_ires)=pdbstructure.Model(1).Atom(iatm).Y;
        zca(CA_ires)=pdbstructure.Model(1).Atom(iatm).Z;
        iatside=0;
    elseif strcmp(pdbstructure.Model(1).Atom(iatm).AtomName,'C') 
        C_ires=C_ires+1;
        atlistC(CA_ires)=iatm;
        xc(C_ires)=pdbstructure.Model(1).Atom(iatm).X;
        yc(C_ires)=pdbstructure.Model(1).Atom(iatm).Y;
        zc(C_ires)=pdbstructure.Model(1).Atom(iatm).Z;
    elseif strcmp(pdbstructure.Model(1).Atom(iatm).AtomName,'O') 
        O_ires=O_ires+1;
        atlistO(O_ires)=iatm;
        xo(O_ires)=pdbstructure.Model(1).Atom(iatm).X;
        yo(O_ires)=pdbstructure.Model(1).Atom(iatm).Y;
        zo(O_ires)=pdbstructure.Model(1).Atom(iatm).Z;
    else
        iatside=iatside+1;
        atlist_side(iatside,CA_ires)=iatm;
        nside(CA_ires)=iatside;
        xside(iatside,CA_ires)=pdbstructure.Model(1).Atom(iatm).X;
        yside(iatside,CA_ires)=pdbstructure.Model(1).Atom(iatm).Y;
        zside(iatside,CA_ires)=pdbstructure.Model(1).Atom(iatm).Z;
        
    end
end

if isequal(N_ires,CA_ires,C_ires)
    nres=N_ires;
    for ires=1:nres-1
        distn_ca=sqrt((xca(ires)-xn(ires))^2+(yca(ires)-yn(ires))^2+(zca(ires)-zn(ires))^2);
        if distn_ca > 2.0 
            'here1'
            skip=true
        end
        distca_c=sqrt((xc(ires)-xca(ires))^2+(yc(ires)-yca(ires))^2+(zc(ires)-zca(ires))^2);
        if distca_c > 2.0 
            'here2'
            skip=true
        end
        distc_n=sqrt((xn(ires+1)-xc(ires))^2+(yn(ires+1)-yc(ires))^2+(zn(ires+1)-zc(ires))^2);
        if distc_n > 2.0 
            'here3'
            skip=true
        end
    end
else
    'here4'
        N_ires
        CA_ires
        C_ires
    skip=true;
end