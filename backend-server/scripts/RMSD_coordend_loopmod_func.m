%% RMSD_coordend_loopmod_func
% 
% function to calculate the rmsd between coordinate atoms on the coordinate
% system at the end of the chain.  All torsions including omega are
% included
%

function [rmsd]=RMSD_coordend_loopmod_func(lengs,angs,tors1,tors2)

%%

nbond=size(lengs,1);
npep=nbond/3;

[A_orig,B_orig]=A_and_B_lengths_func(npep,lengs,angs,tors1);
[A_def,B_def]=A_and_B_lengths_func(npep,lengs,angs,tors2);

o_orig=zeros(3,1);
x_orig=zeros(3,1);
y_orig=zeros(3,1);
z_orig=zeros(3,1);
o_def=zeros(3,1);
x_def=zeros(3,1);
y_def=zeros(3,1);
z_def=zeros(3,1);


o_orig=A_orig*[0;0;0]+B_orig;
x_orig=A_orig*[1;0;0]+B_orig;
y_orig=A_orig*[0;1;0]+B_orig;
z_orig=A_orig*[0;0;1]+B_orig;

o_def=A_def*[0;0;0]+B_def;
x_def=A_def*[1;0;0]+B_def;
y_def=A_def*[0;1;0]+B_def;
z_def=A_def*[0;0;1]+B_def;
    

msd=(o_orig(1,:)-o_def(1,:))^2+(o_orig(2,:)-o_def(2,:))^2+(o_orig(3,:)-o_def(3,:))^2;
msd=msd+(x_orig(1,:)-x_def(1,:))^2+(x_orig(2,:)-x_def(2,:))^2+(x_orig(3,:)-x_def(3,:))^2;
msd=msd+(y_orig(1,:)-y_def(1,:))^2+(y_orig(2,:)-y_def(2,:))^2+(y_orig(3,:)-y_def(3,:))^2;
msd=msd+(z_orig(1,:)-z_def(1,:))^2+(z_orig(2,:)-z_def(2,:))^2+(z_orig(3,:)-z_def(3,:))^2;

rmsd=sqrt(msd/4); 

end