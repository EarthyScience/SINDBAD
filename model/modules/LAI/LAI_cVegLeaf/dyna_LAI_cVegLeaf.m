function [f,fe,fx,s,d,p]=dyna_LAI_cVegLeaf(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of s.cd.LAI from the carbon in the leaves of the previous time step
%
% Inputs:
%   - s.c.cEco(:,cVegLeafZix): carbon in the leave
%   - p.LAI.SLA : SLA parameter: only works if fAPAR is set to cVegLeaf
%
% Outputs:
%   - s.cd.LAI: the value of LAI for current time step
%
% Modifies:
%   - s.cd.LAI
%
% References:
%   - 
%
% Created by:
%   - Simon Besnard (sbesnard)
%
% Versions:
%   - 1.0 on 05.05.2020 (sbesnard)
%   - 1.1 on 04.02.2021 (skoirala): introduced the p.LAI.SLA parameter rather than using p.fAPAR.SLA
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
cVegLeafZix = info.tem.model.variables.states.c.zix.cVegLeaf;
cVegLeaf= s.c.cEco(:,cVegLeafZix);
s.cd.LAI = cVegLeaf.* p.LAI.SLA; % 
end
