%% PhiPsiOmega_from_bbatoms_func

% function to determine phi,psi and omega angles given a pdb code and chain
% identifier

function [phi,psi,omega]=PhiPsiOmega_from_bbatoms_func(nres,xn,yn,zn,xca,yca,zca,xc,yc,zc)


%% Determine all torsion angles

phi=zeros(nres,1);
psi=zeros(nres,1);
omega=zeros(nres,1);

for ires=1:nres
    if ires == 1  
        phi(ires)=NaN;
        [psi(ires)]=torsion_func(xn(ires),yn(ires),zn(ires),xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires),xn(ires+1),yn(ires+1),zn(ires+1));
        [omega(ires)]=torsion_func(xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires),xn(ires+1),yn(ires+1),zn(ires+1),xca(ires+1),yca(ires+1),zca(ires+1));
    elseif ires > 1 && ires < nres
        [phi(ires)]=torsion_func(xc(ires-1),yc(ires-1),zc(ires-1),xn(ires),yn(ires),zn(ires),xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires));
        [psi(ires)]=torsion_func(xn(ires),yn(ires),zn(ires),xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires),xn(ires+1),yn(ires+1),zn(ires+1));
        [omega(ires)]=torsion_func(xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires),xn(ires+1),yn(ires+1),zn(ires+1),xca(ires+1),yca(ires+1),zca(ires+1));
    elseif ires == nres
        [phi(ires)]=torsion_func(xc(ires-1),yc(ires-1),zc(ires-1),xn(ires),yn(ires),zn(ires),xca(ires),yca(ires),zca(ires),xc(ires),yc(ires),zc(ires));
        psi(ires)=NaN;
        omega(ires)=NaN;
    end
end
        
