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

% transfers
[taker,giver]           = find(squeeze(sum(s.cd.p_cFlowAct_A > 0,1)) >= 1);
s.cd.p_cFlowAct_taker    = taker;
s.cd.p_cFlowAct_giver   = giver;

end %function
