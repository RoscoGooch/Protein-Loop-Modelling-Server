%% tors_to_phipsi_func

% Determines the phi psi numbering as you count the torsions



function [tors_to_phipsi]=tors_to_phipsi_func(npep)



%% calculate the indexing

nbond=npep*3;
tors_to_phipsi=zeros(nbond,1);
ibond=0;
iphipsi=0;
for ipep = 1:npep
    ibond=ibond+1;
    iphipsi=iphipsi+1;
    tors_to_phipsi(ibond)=iphipsi;
    ibond=ibond+1;
    ibond=ibond+1;
    iphipsi=iphipsi+1;
    tors_to_phipsi(ibond)=iphipsi;
end
