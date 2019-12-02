function [f,fe,fx,s,d,p] = wBalance_simple(f,fe,fx,s,d,p,info,tix)
% check the water balance in every time step
%
% Inputs:
%	- tix  
%	- info
%   - variables to sum for roTotal(total runoff) and evapTotal (total evap)
%   - check if snow exists to calculate p=rain+snow
%
% Outputs:
%   - d.wBalance.wBal in nPix,nZix
%   - add to variables to store 
%
% Modifies:
% 	- None
%
% References:
%	- 
%
% Created by:
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 11.11.2019
%   - 1.1 on 20.11.2019 (skoirala): use tix for WP because d.[module].[var]
%   is created as nPix,nTix
%%
%--> the total precipitation input
precip=fe.rainSnow.rain(:,tix);
if isfield(fe.rainSnow,'snow')
    precip=precip+fe.rainSnow.snow(:,tix);
end
%--> get the change in storage
dS=s.wd.wTotal-s.prev.s_wd_wTotal;
%--> calculate and store the water balance
d.wBalance.wBal(:,tix) = precip-fx.roTotal(:,tix)-fx.evapTotal(:,tix)-dS;
end
