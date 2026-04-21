
%% determines A and B matrices for a bond (bond angle is the one further along)
function [ABOND,BBOND]=bond_mats(length, angle, torsion)

%%
ABOND=make_rot_mat(angle,torsion);
BBOND=[length;0;0];
