function [f,fe,fx,s,d,p] = prec_cFlowAct_CASA(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % combine all the effects that change the transfers 
    % between carbon pools
    %
    % Inputs:
    %   - p.cCycleBase.cFlowE:     transfer matrix for carbon at ecosystem level
    %   - s.cd.p_cFlowfpSoil_E:    effect of soil on transfer efficiency between pools 
    %   - s.cd.p_cFlowfpVeg_E:     effect of soil on transfer efficiency between pools               
    %   - s.cd.p_cFlowfpSoil_F:    effect of vegetation on transfer fraction between pools 
    %   - s.cd.p_cFlowfpVeg_F      effect of vegetation on transfer fraction between pools
    %
    % Outputs:
    %   - s.cd.p_cFlowAct_E:       effect of soil and vegetation on transfer efficiency between pools
    %   - s.cd.p_cFlowAct_F:       effect of soil and vegetation on transfer fraction between pools
    %   - s.cd.p_cFlowAct_A:       effect of soil and vegetation on actual transfer rates between pools
    %
    % Modifies:
    %   - s.cd.p_cFlowAct_A
    %   - s.cd.p_cFlowAct_E
    %   - s.cd.p_cFlowAct_F
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
    %   - 1.0 on 13.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%@nc : this needs to go in the full...

% effects of soil and veg on the (microbial) efficiency of c flows between carbon pools
tmp                 = repmat(reshape(p.cCycleBase.cFlowE,[1 size(p.cCycleBase.cFlowE)]),info.tem.helpers.sizes.nPix,1,1); 
s.cd.p_cFlowAct_E    = tmp + s.cd.p_cFlowfpSoil_E + s.cd.p_cFlowfpVeg_E;
% effects of soil and veg on the partitioning of c flows between carbon pools
s.cd.p_cFlowAct_F    = s.cd.p_cFlowfpSoil_F + s.cd.p_cFlowfpVeg_F;
% if there is fraction (F) and efficiency is 0, make efficiency 1
ndx                     = s.cd.p_cFlowAct_F > 0 & s.cd.p_cFlowAct_E == 0;
s.cd.p_cFlowAct_E(ndx)  = 1;
% if there is not fraction, but efficiency exists, make fraction == 1 (should give an error if there are more than 1 flux out of this pool)
ndx                     = s.cd.p_cFlowAct_E > 0 & s.cd.p_cFlowAct_F == 0;
s.cd.p_cFlowAct_F(ndx)  = 1;
% build A
s.cd.p_cFlowAct_A        = s.cd.p_cFlowAct_F .* s.cd.p_cFlowAct_E;
% check on matrix
flagUp = repmat(reshape(triu(ones(size(p.cCycleBase.cFlowE)),1),[1 size(p.cCycleBase.cFlowE)]),info.tem.helpers.sizes.nPix,1,1); 
flagLo = repmat(reshape(tril(ones(size(p.cCycleBase.cFlowE)),-1),[1 size(p.cCycleBase.cFlowE)]),info.tem.helpers.sizes.nPix,1,1); 
% of diagonal values of 0 must be between 0 and 1
anyBad     = any(s.cd.p_cFlowAct_A.*(flagLo+flagUp) < 0);
if anyBad 
    error('prec_cCycleBase_simple : negative values in the A matrix!')
end
anyBad     = any(s.cd.p_cFlowAct_A.*(flagLo+flagUp) > 1);
if anyBad 
    error('prec_cCycleBase_simple : values in the A matrix greater than 1!')
end
% in the lower and upper part of the matrix A the sums have to be lower than 1
anyBad     = any(sum(s.cd.p_cFlowAct_A.*flagLo,2)>1);
if anyBad
    error('prec_cCycleBase_simple : sum of cols higher than one in lower!')
end
anyBad     = any(sum(s.cd.p_cFlowAct_A.*flagUp,2)>1);
if anyBad
    error('prec_cCycleBase_simple : sum of cols higher than one in upper!')
end
% transfers
[taker,giver]           = find(squeeze(sum(s.cd.p_cFlowAct_A > 0,1)) >= 1);
s.cd.p_cFlowAct_taker    = taker;
s.cd.p_cFlowAct_giver   = giver;
% if there is flux order check that is consistent
if ~isfield(p.cCycleBase,'fluxOrder')
    p.cCycleBase.fluxOrder = 1:numel(taker);
else
    if numel(p.cCycleBase.fluxOrder) ~= numel(taker)
        error(['ERR : cFlowAct_simple : '...
            'numel(p.cCycleBase.fluxOrder) ~= numel(taker)'])
    end
end
end %function
