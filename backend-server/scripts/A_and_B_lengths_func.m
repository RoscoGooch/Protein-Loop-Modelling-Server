%% A_and_B_lengths_func

% FUNCTION TO CALCULATE A AND B MATRICES FOR GIVEN TORSION AND BOND ANGLES

function [A,B]=A_and_B_lengths_func(npep,lengs,angs,tors)


%% bond length and angles and torsions are not standard


A=eye(3);
APREV=eye(3);
BPREV=0*ones(3,1);
ibond=1;
for ipep = 1:npep
    [APEP,BPEP]=peptide_mats(lengs(ibond),angs(ibond),tors(ibond),lengs(ibond+1),angs(ibond+1),tors(ibond+1),lengs(ibond+2),angs(ibond+2),tors(ibond+2));
    A=APREV*APEP;
    B=APREV*BPEP+BPREV;
    APREV=A;
    BPREV=B;
    ibond=ibond+3;
end
