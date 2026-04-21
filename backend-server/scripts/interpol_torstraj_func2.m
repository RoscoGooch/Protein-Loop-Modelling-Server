%% interpol_torstraj_func2

% Takes the torsion angle trajectory and uses interpolation to create torsions such that
% the torsion that changes the most is samples at approximately 1 degree
% intervals

function [nmod,torsmod]=interpol_torstraj_func2(n_iterstop,npep,nphipsi,phipsi_index,tors_initial,tors_final,torstraj)

torstraj_ini=[tors_initial';torstraj(1:n_iterstop,:)];
phipsitrj_path(1)=0.0;
phipsi_full=0.0;
for iter=2:(1+n_iterstop)
    phipsitrj_incr_full=0.0;
    for iphipsi=1:nphipsi
        phipsitrj_incr=torstraj_ini(iter,phipsi_index(iphipsi))-torstraj_ini(iter-1,phipsi_index(iphipsi));
% need to take care if it crosses -180,180 boundary      
        phipsitrj_incr=oneeighty(phipsitrj_incr);
        phipsitrj_incr_full=phipsitrj_incr_full+phipsitrj_incr^2;
    end
    phipsi_full=phipsi_full+sqrt(phipsitrj_incr_full);
    phipsitrj_path(iter)=phipsi_full;
end


% determine an interval based on 1 degree change for each phi psi
intvr=sqrt(nphipsi);
pathlength=phipsitrj_path(1+n_iterstop);
n_intv=round(pathlength/intvr);
intv=pathlength/n_intv;
path_incr(1)=0.0;
for i=1:n_intv
    path_incr(i+1)=i*intv;
end

% create trajectories without -180,180 barrier crossings
for iphipsi=1:nphipsi
    phipsitrj=torstraj_ini(:,phipsi_index(iphipsi));
% need to take care if it crosses -180,180 boundary
    phipsi1=phipsitrj(1);
    phipsitrj_incr(1)=0.0;
    phipsidiff_tot=0.0;
    for iter=2:n_iterstop+1
        phipsidiff=phipsitrj(iter)-phipsitrj(iter-1);
        phipsidiff=oneeighty(phipsidiff);
        phipsidiff_tot=phipsidiff_tot+phipsidiff;
        phipsitrj_incr(iter)=phipsidiff_tot;
    end
    
%% call interpolation rountine

    diffinp1=interp1(phipsitrj_path,phipsitrj_incr,path_incr);
    ninp=size(diffinp1',1);
% just in case interpolation goes wrong on end points (as it did once)
    diffinp1(1)=0.0;
    diffinp1(ninp)=phipsitrj_incr(1+n_iterstop);

    for inp=1:ninp
        phipsitrjinp(inp,iphipsi)=phipsi1+diffinp1(inp);
    end
    phipsitrjinp(:,iphipsi)=oneeighty(phipsitrjinp(:,iphipsi));
end

%% put into torsion array; creating nmod of them

omega_index=omega_bonds(npep);
nomega=size(omega_index,2);
nmod=n_intv;
omega_initial=tors_initial(omega_index);
nbond=3*npep;
torsmod=zeros(nmod,nbond);
for imod=1:nmod
    for iphipsi=1:nphipsi
        torsmod(imod,phipsi_index(iphipsi))=phipsitrjinp(imod+1,iphipsi);
    end
    for iomega=1:nomega
        torsmod(imod,omega_index(iomega))=omega_initial(iomega);
    end
end
        