function [f,fe,fx,s,d,p] = getStates_simple(f,fe,fx,s,d,p,info,tix)
% gets the amount of water available for the current time step
%
% Inputs:
%    - tix 
%    - amount of rainfall
%
% Outputs:
%   - s.wd.WBP: the amount of liquid water input to the system
%
% Modifies:
%     - None
% References:
%    - 
%
% Created by:
%   - Martin Jung (mjung)
%   - Nuno Carvalhais (ncarval)
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 19.11.2019 (skoirala): added the documentation and cleaned the code, added json with development stage
%
%% 

%--> Water Balance Pool
s.wd.WBP  = fe.rainSnow.rain(:,tix);
end

