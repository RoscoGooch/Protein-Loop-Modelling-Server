%% Loop_Target_func2

% Adpated from Torsion_itto_point2. The aim is to get as close to the phi psi angles of
% target set under fixed end groups condition. This differs from
% Loop_Target_func in that the targeting can happen in a subspace of
% selected phi psi angles (see notebook page 141).

function [n_iterstop,torstraj,tors_final,rmsd_initial,normlamda,delta_targ_final,distfinal]=Loop_Target_func2(n_iter,lengs,angs,constrset,npep,nbond,nphipsi,phipsi_notconstr_index,n_notconstr,nfree,tors_initial,tors_target_mask,tors_target)

%% Initialise

notconstr=1:n_notconstr

%% determine quantities before iteration

% determine vector from initial torsion to target torsion
delta_targ=tors_target-(tors_initial.*tors_target_mask);

delta_targ=oneeighty(delta_targ);

dist(1)=norm(delta_targ);

%% iterate along the nullspace vector
tors=tors_initial;
torstraj=zeros(n_iter,nbond);
itfact=0.1;
null_tors=zeros(nbond,nfree);
n_iterstop=n_iter;
for iter=1:n_iter
    [nullsp,nphipsi,omega,TORFULLMAT]=nulltorsion_loopmod(npep,constrset,lengs,angs,tors);
    
    null_tors(phipsi_notconstr_index,:)=nullsp;
    
% seems the (notconstr,:) is superfluous so replaced by above
%   null_tors(phipsi_notconstr_index,:)=nullsp(notconstr,:);

    lamda=null_tors'*delta_targ;  
    tors=tors+null_tors*lamda*itfact;
    [tors]=oneeighty(tors);
    delta_targ=tors_target-(tors.*tors_target_mask);
    delta_targ=oneeighty(delta_targ);    

    torstraj(iter,:)=tors;    
    dist(iter)=norm(delta_targ(phipsi_notconstr_index));
    [rmsd_initial]=RMSD_coordend_loopmod_func(lengs,angs,tors_initial,tors); 
    
% normlamda below is zero when it converges (projection onto nullspace of delta_targ is zero)
%
    normlamda=norm(lamda)
    [norm(lamda) dist(iter) rmsd_initial]
    
    if normlamda < 0.000001 || dist(iter) < 0.1
        break
    end
    
end
n_iterstop=iter;
tors_final=tors;
distfinal=dist(iter);
delta_targ_final=delta_targ;
