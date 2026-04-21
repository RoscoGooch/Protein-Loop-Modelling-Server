%% bond_length_func

% function to determine the bond length given coordinates of two atoms

function [lengs]=bond_length_func(x1,y1,z1,x2,y2,z2)

% determine length

x21=x2-x1;
y21=y2-y1;
z21=z2-z1;
lengs=sqrt(x21^2+y21^2+z21^2);
