function [f,fe,fx,s,d,p]=dyna_LAI_cVegLeaf(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of s.cd.LAI from the carbon in the leaves of the previous time step
%
% Inputs:
%   - s.c.cEco(:,cVegLeafZix): carbon in the leave
%   - s.cd.p_fAPAR_SLA : SLA parameter
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
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
cVegLeafZix = info.tem.model.variables.states.c.zix.cVegLeaf;
cVegLeaf= s.c.cEco(:,cVegLeafZix);
s.cd.LAI = cVegLeaf.* p.fAPAR.SLA;
end
