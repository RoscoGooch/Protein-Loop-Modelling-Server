%% create the rotation matrix for one bond angle and one torsion angle
function rotationmatrix = make_rot_mat(angle,torsion)

%%
angle=angle*pi/180.0;
torsion=torsion*pi/180.0;
rotationmatrix=[-cos(angle) -sin(angle) 0; sin(angle)*cos(torsion) -cos(angle)*cos(torsion) -sin(torsion); sin(angle)*sin(torsion) -cos(angle)*sin(torsion) cos(torsion)];