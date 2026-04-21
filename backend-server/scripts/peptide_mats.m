%% order is changed compared to MATHCAD calculation
% ac refers to Calpha-N distance etc as defined in paper TABLE 1
%%

function [APEP,BPEP]= peptide_mats(ac,acn,psi,cn,cna,omega,na,nac,phip1)

%%  1st bond of 1st residue

[A_AC,B_AC]=bond_mats(ac,acn,psi);

%% 2nd bond of 1st residue

[A_CN,B_CN]=bond_mats(cn,cna,omega);

%% 3rd bond of 1st residue

[A_NA,B_NA]=bond_mats(na,nac,phip1);

%% create matrices for 1st residue

APEP=A_AC*A_CN*A_NA;
BPEP=A_AC*A_CN*B_NA+A_AC*B_CN+B_AC;
