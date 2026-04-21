%% torsion_func

% function to determine the torsion angle given coordinates of four atoms

function [tor]=torsion_func(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4)

% determine torsion

V23(1)=x2-x3;
V23(2)=y2-y3;
V23(3)=z2-z3;

V21(1)=x2-x1;
V21(2)=y2-y1;
V21(3)=z2-z1;

V43(1)=x4-x3;
V43(2)=y4-y3;
V43(3)=z4-z3;

length=norm(V23)^2;

scalar=dot(V21,V23);
scalar=scalar/length;
Vim=V21-scalar*V23;

scalar=dot(V43,V23);
scalar=scalar/length;
Vln=-V43+scalar*V23;


lengthim=norm(Vim);
lengthln=norm(Vln);
scalar=dot(Vim,Vln);
cs=scalar/(lengthim*lengthln);

V=cross(V23,V43);
scalar=dot(V21,V);
tor=-sign(scalar)*acos(cs)*180/pi;
