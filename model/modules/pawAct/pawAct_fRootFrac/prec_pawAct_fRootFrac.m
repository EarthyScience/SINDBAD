function [f,fe,fx,s,d,p]=prec_pawAct_fRootFrac(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the maximum fraction of water that root can uptake from soil layers as constant
%
% Inputs:
%   - p.rootFrac.constantRootFrac
%   - s.wd.maxRootD
%
% Outputs:
%   - s.wd.pawAct as nPix,nZix for wSoil
%
% Modifies:
% 	- None
% 
% References:
%	- 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 21.11.2019
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 

%--> create the arrays to fill with pawAct
s.wd.pawAct     =   info.tem.helpers.arrays.onespixzix.w.wSoil;

end