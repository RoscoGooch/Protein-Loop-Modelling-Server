%% phi_bonds

% This determines the bond numbers for the phi torsions



function [phi]=phi_bonds(npep)



%% calculate

nbond=npep*3;

ibond=0;
iphi=0;
for ipep = 1:npep
    ibond=ibond+1;
    ibond=ibond+1;
    ibond=ibond+1;
    iphi=iphi+1;
    phi(iphi)=ibond;
end
