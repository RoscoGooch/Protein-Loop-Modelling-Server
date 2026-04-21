%% bond_angle_func

% function to determine the bond angle given coordinates of three atoms

function [angle]=bond_angle_func(x1,y1,z1,x2,y2,z2,x3,y3,z3)

% determine angle

x12=x1-x2;
y12=y1-y2;
z12=z1-z2;
len=sqrt(x12^2+y12^2+z12^2);
x12=x12/len;
y12=y12/len;
z12=z12/len;
 
x32=x3-x2;
y32=y3-y2;
z32=z3-z2;
len=sqrt(x32^2+y32^2+z32^2);
x32=x32/len;
y32=y32/len;
z32=z32/len;
 
scal=x12*x32+y12*y32+z12*z32;
angle=acos(scal);
angle=angle*180.0/pi;
