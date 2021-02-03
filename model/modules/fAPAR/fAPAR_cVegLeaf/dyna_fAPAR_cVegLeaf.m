function [f,fe,fx,s,d,p]=dyna_fAPAR_cVegLeaf(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Compute FAPAR based on carbon pool of the leave, SLA, kLAI
%
% Inputs:
%    - p.fAPAR.SLA  
%    - p.fAPAR.kLAI
%    - s.c.cEco.cVegLeaf
%
% Outputs:
%   - s.cd.fAPAR: the value of fAPAR for current time step
%
% Modifies:
%     - s.cd.fAPAR
%
% References:
%    - 
%
% Created by:
%   - Simon Besnard (sbesnard)
%
% Versions:
%   - 1.0 on 24.04.2020 (sbesnard): new approach
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
cVegLeafZix = info.tem.model.variables.states.c.zix.cVegLeaf;
cVegLeaf= s.c.cEco(:,cVegLeafZix);
s.cd.fAPAR = 1-exp(-(cVegLeaf.*p.fAPAR.SLA .* p.fAPAR.kLAI));
end
