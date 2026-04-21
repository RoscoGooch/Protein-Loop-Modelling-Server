%% Make_PDBstruct_Tortraj_func

% Program that takes trajectory of torsion angles to create a trajectory
% in cartesian coordinates including side chains. Method uses the following
% strategy.  A virutal atom is created at 1,0,0 in the system
% coordinates.  The torsion and angle for the bond that joins the system to
% the virtual atom and the virtual atom to the first real atom (c-alpha residue 1)
% are calculated. This will allow us to get the A and B matrices to transform from the
% system coordinates to the coordinate system on each C-alpha atom.  The
% side chain coordinates will not change in this coordinates system.
% Therefore as A and B change with changes in torsions we can use the new A
% and B to calculate the side chain coordinates in system coordinates.


function [segstruct_traj]=Make_PDBstruct_Tortraj_func(nmod,natseg,nres,segstruct,xn,yn,zn,xca,yca,zca,xc,yc,zc,xo,yo,zo,nside,xside,yside,zside,atlistN,atlistCA,atlistC,atlistO,atlist_side,lengs,angs,tors_initial,torstraj)

%% Calculate torsions and angles related to virtual atom
%atlist_side
x_virt=1.0;
y_virt=0.0;
z_virt=0.0;

% calculate distance between virtual atom and first real C-alpha atom

dist=sqrt((xca(1)-x_virt)^2+(yca(1)-y_virt)^2+(zca(1)-z_virt)^2);

% calculate (origin-virtual atom-first atom) bond angle
[O_V_CA_ang]=bond_angle_func(0,0,0,x_virt,y_virt,z_virt,xca(1),yca(1),zca(1));

% calculate (virtual atom-first atom-second atom) bond angle
[V_CA_C_ang]=bond_angle_func(x_virt,y_virt,z_virt,xca(1),yca(1),zca(1),xc(1),yc(1),zc(1));

% calculate the torsion for origin virtual atom bond
[O_V_tor]=torsion_func(0,1,0,0,0,0,1,0,0,xca(1),yca(1),zca(1));

% calculate the torsion for origin virtual atom bond
[V_CA_tor]=torsion_func(0,0,0,1,0,0,xca(1),yca(1),zca(1),xc(1),yc(1),zc(1));

% calculate the transformation matrices A and B for these bonds
[A_sys,B_sys]=bond_mats(1.0,O_V_CA_ang,O_V_tor);
[A_virt,B_virt]=bond_mats(dist,V_CA_C_ang,V_CA_tor);

nbond=(nres-1)*3;
APREV=eye(3);
BPREV=zeros(3,1);
% from virtual atom to system coordinates
A_virt_to_sys=APREV*A_sys;
B_virt_to_sys=APREV*B_sys+BPREV;
APREV=A_virt_to_sys;
BPREV=B_virt_to_sys;
% from first c-alpha atom to system via virtual
A_ca1_to_sys=APREV*A_virt;
B_ca1_to_sys=APREV*B_virt+BPREV;
APREV=A_ca1_to_sys;
BPREV=B_ca1_to_sys;

APREV_SYS=APREV;
BPREV_SYS=BPREV;

%% Calculate transformation matrices between each backbone atom and system

% first torsion is no longer psi but is that using virtual atom rather than N
tors_n1=tors_initial(1);
[tors_initial(1)]=torsion_func(x_virt,y_virt,z_virt,xca(1),yca(1),zca(1),xc(1),yc(1),zc(1),xn(2),yn(2),zn(2));
tors1_diff=tors_initial(1)-tors_n1;
for ibond=1:nbond
    [A_bond,B_bond]=bond_mats(lengs(ibond),angs(ibond),tors_initial(ibond));
    A_to_sys(:,:,ibond)=APREV*A_bond;
    B_to_sys(:,ibond)=APREV*B_bond+BPREV;
    APREV=A_to_sys(:,:,ibond);
    BPREV=B_to_sys(:,ibond);
end

%% Transform side chain coordinates from system to local frame on corresponding C-alpha

% determine side chain coordinates in system frame
ibond=0;
for ires=1:nres
    if ires == 1    
        ibond=ibond+1;
    elseif ires >= 1 && ires <=nres-1
        ibond=ibond+1;
        ibond=ibond+1;
% now transform side chain coordinates to coordinate system of each C-alpha
        for iatside=1:nside(ires)
            side_local(:,iatside,ires)=inv(A_to_sys(:,:,ibond))*([xside(iatside,ires);yside(iatside,ires);zside(iatside,ires)]-B_to_sys(:,ibond));
        end
        ibond=ibond+1;      
    else
        ibond=ibond+1;            
    end
end
%% Transform backbone oxygen coordinates from system to local frame on corresponding C atom

% determine oxygen coordinates in system frame
ibond=0;
for ires=1:nres
    if ires == 1    
        ibond=ibond+1;
        ox_local(:,ires)=inv(A_to_sys(:,:,ibond))*([xo(ires);yo(ires);zo(ires)]-B_to_sys(:,ibond));
    elseif ires >= 1 && ires <=nres-1
        ibond=ibond+1;
        ibond=ibond+1;
% now transform side chain coordinates to coordinate system of each C-alpha
        for iatside=1:nside(ires)
            side_local(:,iatside,ires)=inv(A_to_sys(:,:,ibond))*([xside(iatside,ires);yside(iatside,ires);zside(iatside,ires)]-B_to_sys(:,ibond));
        end
        ibond=ibond+1; 
        ox_local(:,ires)=inv(A_to_sys(:,:,ibond))*([xo(ires);yo(ires);zo(ires)]-B_to_sys(:,ibond));
    elseif ires==nres
        ibond=ibond+1;            
    end
end

%% Convert to Cartesian coordinates in system frame for output

segstruct_traj.Model(1)=segstruct.Model;
% determine transformation matrices A and B
for imod=1:nmod
    tors=torstraj(imod,:);
    
% the following converts from the torsion calculated originally using
% the N of residue 1 to the torsion using the virtual atom
    tors(1)=tors(1)+tors1_diff;
    
    APREV=APREV_SYS;
    BPREV=BPREV_SYS;

    for ibond=1:nbond
        [A_bond,B_bond]=bond_mats(lengs(ibond),angs(ibond),tors(ibond));
        
% these are the required transformation matrices
        A_to_sys(:,:,ibond)=APREV*A_bond;
        B_to_sys(:,ibond)=APREV*B_bond+BPREV;
        
        APREV=A_to_sys(:,:,ibond);
        BPREV=B_to_sys(:,ibond);
    end

% now transform all coordinates including those of side chains and backbone oxygens 
% to system coordinates

    ibond=0;
    for ires=1:nres
        if ires == 1 
            iatm=atlistN(ires);
            x_trans(iatm)=xn(ires);
            y_trans(iatm)=yn(ires);
            z_trans(iatm)=zn(ires);
            iatm=atlistCA(ires);
            x_trans(iatm)=xca(ires);
            y_trans(iatm)=yca(ires);
            z_trans(iatm)=zca(ires);
            for iatside=1:nside(ires)
                iatm=atlist_side(iatside,ires);
                x_trans(iatm)=xside(iatside,ires);
                y_trans(iatm)=yside(iatside,ires);
                z_trans(iatm)=zside(iatside,ires);
            end
            ibond=ibond+1;
            iatm=atlistC(ires);
            x_trans(iatm)=B_to_sys(1,ibond);
            y_trans(iatm)=B_to_sys(2,ibond);
            z_trans(iatm)=B_to_sys(3,ibond);
            ox_sys(:,ires)=A_to_sys(:,:,ibond)*ox_local(:,ires)+B_to_sys(:,ibond);
            iatm=atlistO(ires);
            x_trans(iatm)=ox_sys(1,ires);
            y_trans(iatm)=ox_sys(2,ires);
            z_trans(iatm)=ox_sys(3,ires);           
        elseif ires >= 1 && ires <=nres-1
            ibond=ibond+1;
            iatm=atlistN(ires);
            x_trans(iatm)=B_to_sys(1,ibond);
            y_trans(iatm)=B_to_sys(2,ibond);
            z_trans(iatm)=B_to_sys(3,ibond);
            ibond=ibond+1;
            iatm=atlistCA(ires);
            x_trans(iatm)=B_to_sys(1,ibond);
            y_trans(iatm)=B_to_sys(2,ibond);
            z_trans(iatm)=B_to_sys(3,ibond);
% now transform side chain atoms (this is what it's been all about)
            for iatside=1:nside(ires)
                side_sys(:,iatside,ires)=A_to_sys(:,:,ibond)*side_local(:,iatside,ires)+B_to_sys(:,ibond);
                iatm=atlist_side(iatside,ires);
                x_trans(iatm)=side_sys(1,iatside,ires);
                y_trans(iatm)=side_sys(2,iatside,ires);
                z_trans(iatm)=side_sys(3,iatside,ires);
            end
            ibond=ibond+1;
            iatm=atlistC(ires);
            x_trans(iatm)=B_to_sys(1,ibond);
            y_trans(iatm)=B_to_sys(2,ibond);
            z_trans(iatm)=B_to_sys(3,ibond);
            ox_sys(:,ires)=A_to_sys(:,:,ibond)*ox_local(:,ires)+B_to_sys(:,ibond);
            iatm=atlistO(ires);
            x_trans(iatm)=ox_sys(1,ires);
            y_trans(iatm)=ox_sys(2,ires);
            z_trans(iatm)=ox_sys(3,ires);
        elseif ires==nres
            ibond=ibond+1;
            iatm=atlistN(ires);
            x_trans(iatm)=B_to_sys(1,ibond);
            y_trans(iatm)=B_to_sys(2,ibond);
            z_trans(iatm)=B_to_sys(3,ibond);
            iatm=atlistCA(ires);
            x_trans(iatm)=xca(ires);
            y_trans(iatm)=yca(ires);
            z_trans(iatm)=zca(ires);
            for iatside=1:nside(ires)
                iatm=atlist_side(iatside,ires);
                x_trans(iatm)=xside(iatside,ires);
                y_trans(iatm)=yside(iatside,ires);
                z_trans(iatm)=zside(iatside,ires);
            end
            iatm=atlistC(ires);
            x_trans(iatm)=xc(ires);
            y_trans(iatm)=yc(ires);
            z_trans(iatm)=zc(ires);
            iatm=atlistO(ires);
            x_trans(iatm)=xo(ires);
            y_trans(iatm)=yo(ires);
            z_trans(iatm)=zo(ires);
        end
    end
    segstruct_traj.Model(imod+1)=segstruct.Model;
    for iatm=1:natseg
        segstruct_traj.Model(imod+1).Atom(iatm).X=x_trans(iatm);
        segstruct_traj.Model(imod+1).Atom(iatm).Y=y_trans(iatm);
        segstruct_traj.Model(imod+1).Atom(iatm).Z=z_trans(iatm);
    end
end