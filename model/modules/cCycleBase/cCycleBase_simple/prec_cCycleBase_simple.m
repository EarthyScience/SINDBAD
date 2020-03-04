function [f,fe,fx,s,d,p] = prec_cCycleBase_simple(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Compute carbon to nitrogen ratio and  annual turnover rates
    %
    % Inputs:
    %   - p.cCycleBase.C2Nveg:            carbon to nitrogen ratio in vegetation pools
    %   - p.cCycleBase.annk:              turnover rate of ecosystem carbon pools 
    %   - p.cCycleBase.cFlowA:            Transfer matrix for carbon at ecosystem level 
    % 
    %
    % Outputs:
    %   - s.cd.p_cCycleBase_C2Nveg:    carbon to nitrogen ratio in vegetation pools
    %   - s.cd.p_cCycleBase_annk:      turnover rate of ecosystem carbon pools  
    %
    % Modifies:
    %   - 
    %
    % References:
    %   - Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
    %     Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
    %     production: A process model based on global satellite and surface data.
    %     Global Biogeochemical Cycles. 7: 811-841.
    %
    % Created by:
    %   - ncarvalhais 
    %
    % Versions:
    %   - 1.0 on 28.02.2020 (sbesnard)
    %
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%carbon to nitrogen ratio (gC.gN-1)
s.cd.p_cCycleBase_C2Nveg        =   zeros(info.tem.helpers.sizes.nPix,numel(info.tem.model.variables.states.c.zix.cVeg)); %sujan
for zix = info.tem.model.variables.states.c.zix.cVeg
    s.cd.p_cCycleBase_C2Nveg(:,zix)    =   p.cCycleBase.C2Nveg(zix);
end

% annual turnover rates
s.cd.p_cCycleBase_annk = reshape(repelem(p.cCycleBase.annk,info.tem.helpers.sizes.nPix),info.tem.helpers.sizes.nPix,info.tem.model.variables.states.c.nZix.cEco); %sujan

% the sum of A per column below the diagonals is always < 1 
flagUp = triu(ones(size(p.cCycleBase.cFlowA)),1);
flagLo     = tril(ones(size(p.cCycleBase.cFlowA)),-1);
% of diagonal values of 0 must be between 0 and 1
anyBad     = any(p.cCycleBase.cFlowA.*(flagLo+flagUp) < 0);
if anyBad 
    error('prec_cCycleBase_simple : negative values in the A matrix!')
end
anyBad     = any(p.cCycleBase.cFlowA.*(flagLo+flagUp) > 1);
if anyBad 
    error('prec_cCycleBase_simple : values in the A matrix greater than 1!')
end
% in the lower and upper part of the matrix A the sums have to be lower than 1
anyBad     = any(sum(p.cCycleBase.cFlowA.*flagLo,1)>1);
if anyBad
    error('prec_cCycleBase_simple : sum of cols higher than one in lower!')
end
anyBad     = any(sum(p.cCycleBase.cFlowA.*flagUp,1)>1);
if anyBad
    error('prec_cCycleBase_simple : sum of cols higher than one in upper!')
end
end %function 