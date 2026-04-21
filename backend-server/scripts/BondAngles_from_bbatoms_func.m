%% BondAngles_from_bbatoms_func

% function to determine backbone bond angles given pdb code and chain identifier

function [n_ang,ca_ang,c_ang]=BondAngles_from_bbatoms_func(nres,xn,yn,zn,xca,yca,zca,xc,yc,zc)


%% Determine all bond angles
for ires=1:nres
    if ires == 1         
        n_ang(ires)=NaN;
        [ca_ang(ires)]=bond_angle_func(xn(ires),yn(ires),zn(ires),xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires));
        [c_ang(ires)]=bond_angle_func(xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires),xn(ires+1),yn(ires+1),zn(ires+1));
    elseif ires > 1 && ires < nres
        [n_ang(ires)]=bond_angle_func(xc(ires-1),yc(ires-1),zc(ires-1),xn(ires),yn(ires),zn(ires),xca(ires),yca(ires),zca(ires));
        [ca_ang(ires)]=bond_angle_func(xn(ires),yn(ires),zn(ires),xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires));
        [c_ang(ires)]=bond_angle_func(xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires),xn(ires+1),yn(ires+1),zn(ires+1));
    elseif ires == nres
        [n_ang(ires)]=bond_angle_func(xc(ires-1),yc(ires-1),zc(ires-1),xn(ires),yn(ires),zn(ires),xca(ires),yca(ires),zca(ires));
        [ca_ang(ires)]=bond_angle_func(xn(ires),yn(ires),zn(ires),xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires));
        c_ang(ires)=NaN;
    end
end