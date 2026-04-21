%% nulltorsion_loopmod

% This is basically torsion_only as a function, it:

% FINDS SOLUTION OF LOCAL DEFORMATION USING TORSION ANGLES ONLY.  REQUIRED
% TO SOLVE A HOMOGENOUS SET OF EQUATIONS. THE MATRIX TORFULLMAT HAS RANK 6 AND THE
% COMMAND null(TORFULLMAT) GIVES A BASIS SET IN N-6. Constrains a phi or
% psi angle. See line 127
%


function [tornullsp,nphipsi,omega,TORFULLMAT]=nulltorsion_loopmod(npep,constrset,lengs,angle,tor)


%% calculate A matrices for each bond

nbond=npep*3;

ibond=0;
iomega=0;
for ipep = 1:npep
    ibond=ibond+1;
    [A,B]=bond_mats(lengs(ibond),angle(ibond),tor(ibond));
    AMAT(:,:,ibond)=A;
    ibond=ibond+1;
    iomega=iomega+1;
    omega(iomega)=ibond;
    [A,B]=bond_mats(lengs(ibond),angle(ibond),tor(ibond));
    AMAT(:,:,ibond)=A;
    ibond=ibond+1;
    [A,B]=bond_mats(lengs(ibond),angle(ibond),tor(ibond));
    AMAT(:,:,ibond)=A;   
end

% determine number of phi,psi angles

omegasize=size(omega);
nomega=omegasize(1,2);
nphipsi=nbond-nomega;

%% calculate the transformation matrices from coordinate systems on each atom to that of first atom.

AMATBOND(:,:,1)=AMAT(:,:,1);
for ibond = 2:nbond
    AMATBOND(:,:,ibond)=AMATBOND(:,:,ibond-1)*AMAT(:,:,ibond);
end

%%  Then calculate the unit vector components for the torsion and the bond angles in the coordinate system of the first atom

TORVEC(:,1)=[1;0;0];
for ibond = 2:nbond
    TORVEC(:,ibond)=AMATBOND(:,:,ibond-1)*[1;0;0];
end


%% ROTATIONAL COMPONENT
% put the vectors in a matrix by horizontal concatenation

TORMAT=TORVEC(:,1);
for ibond = 2:nbond
    TORMAT=[TORMAT TORVEC(:,ibond)];
end


%% Find position vectors from bond to final atom

ibond=0;
for ipep = 1:npep
    ibond=ibond+1;
    bondlength(ibond)=lengs(ibond);
    ibond=ibond+1;
    bondlength(ibond)=lengs(ibond);
    ibond=ibond+1;
    bondlength(ibond)=lengs(ibond);
end

POSVEC(:,1,1)=[0;0;0];
for ibond=2:nbond
    POSVEC(:,1,ibond)=[0;0;0];
end
%
for ibond=1:nbond-1
    for jbond=ibond+1:nbond
        POSVEC(:,1,ibond)=POSVEC(:,1,ibond)+bondlength(jbond)*TORVEC(:,jbond);
    end
end


%%  now do cross products to determine coefficients
% for torsions

for ibond=1:nbond
    TORDISPVEC(:,ibond)=cross(TORVEC(:,ibond),POSVEC(:,1,ibond));
end

%% TRANSLATIONAL COMPONENT
% put the vectors in a matrix by horizontal concatenation

TORDISPMAT=TORDISPVEC(:,1);
for ibond = 2:nbond
    TORDISPMAT=[TORDISPMAT TORDISPVEC(:,ibond)];
end


%% FINAL OPERATION OF CONCATENATING MATRICES
% vertically concatenate the two torsion matrices and the two angle matrices

TORFULLMAT=[TORMAT;TORDISPMAT];

%remove omega torsions

TORFULLMAT(:,[omega])=[];

%
% remover constrained phi psi
% 

TORFULLMAT(:,constrset)=[];

%% DETERMINE SOLUTUON 

tornullsp=null(TORFULLMAT);
%[utor,stor,vtor]=svd(TORFULLMAT)

