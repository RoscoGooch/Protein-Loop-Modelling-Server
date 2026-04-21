%% omega_bonds

% This determines the bond numbers for the omega torsion



function [omega_index]=omega_bonds(npep)



%% calculate A matrices for each bond

nbond=npep*3;

ibond=0;
iomega=0;
for ipep = 1:npep
    ibond=ibond+1;
    ibond=ibond+1;
    iomega=iomega+1;
    omega_index(iomega)=ibond;
    ibond=ibond+1;  
end
