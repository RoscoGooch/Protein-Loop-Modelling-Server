%% oneeighty
%
% Simply resets angles to -180 to +180 range
%
function [tors]=oneeighty(tors)

    n=length(tors);
    for ic=1:n
       if tors(ic) > 180 
           tors(ic)=-(360-tors(ic));
       end
       if tors(ic) < -180
           tors(ic)=360+tors(ic);
       end
    end