%% psi_bonds

% This determines the bond numbers for the psi torsions



function [psi]=psi_bonds(npep)



%% calculate 

nbond=npep*3;

ibond=0;
ipsi=0;
for ipep = 1:npep
    ibond=ibond+1;
    ipsi=ipsi+1;
    psi(ipsi)=ibond;
    ibond=ibond+1;
    ibond=ibond+1;
end
