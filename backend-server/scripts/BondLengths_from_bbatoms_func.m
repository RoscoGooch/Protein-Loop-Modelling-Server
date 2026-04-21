%% BondLengths_from_bbatoms_func

% function to determine backbone bond lengths given pdb code and chain identifier


function [nca,cac,cn]=BondLengths_from_bbatoms_func(nres,xn,yn,zn,xca,yca,zca,xc,yc,zc)


%% Determine all bond lengths

for ires=1:nres
    if ires >= 1 && ires < nres 
        nca(ires)=bond_length_func(xn(ires),yn(ires),zn(ires),xca(ires),yca(ires),zca(ires));
        cac(ires)=bond_length_func(xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires));
        cn(ires)=bond_length_func(xc(ires),yc(ires),zc(ires),xn(ires+1),yn(ires+1),zn(ires+1));
    elseif ires == nres
        nca(ires)=bond_length_func(xn(ires),yn(ires),zn(ires),xca(ires),yca(ires),zca(ires));
        cac(ires)=bond_length_func(xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires)); 
    end
end