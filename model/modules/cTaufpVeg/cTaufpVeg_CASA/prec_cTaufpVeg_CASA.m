function [f,fe,fx,s,d,p] = prec_cTaufpVeg_CASA(f,fe,fx,s,d,p,info)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Compute effect of vegetation type on turnover rates (k)
    %
    % Inputs:
    %   - p.pVeg.PFT: 
    %   - p.cTaufpVeg.C2LIGNIN: parameter for fraction of C to ligning
    %   - p.cTaufpVeg.MTFA:   
    %   - p.cTaufpVeg.MTFB:
    %   - p.cTaufpVeg.NONSOL2SOLLIGNIN:
    %   - p.cTaufpVeg.LIGEFFA:
    %   - p.cTaufpVeg.LITC2N_per_PFT: carbon-to-nitrogen ratio in litter
    %   - p.cTaufpVeg.LIGNIN_per_PFT: fraction of litter that is lignin
    %
    % Outputs:
    %   - s.cd.p_cTaufpVeg_kfVeg:
    %   - s.cd.p_cTaufpVeg_LITC2N:
    %   - s.cd.p_cTaufpVeg_LIGNIN:
    %   - s.cd.p_cTaufpVeg_MTF:
    %   - s.cd.p_cTaufpVeg_SCLIGNIN: 
    %   - s.cd.p_cTaufpVeg_LIGEFF:
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
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


% s.cd.p_cCycleBase_annk                  =   p.cCycleBase.annk; %sujan
% initialize the outputs to ones
s.cd.p_cTaufpVeg_C2LIGNIN               =   p.cTaufpVeg.C2LIGNIN .* info.tem.helpers.arrays.onespix; %sujan
s.cd.p_cTaufpVeg_kfVeg                  =   info.tem.helpers.arrays.onespixzix.c.cEco; %sujan
%% adjust the annk that are pft dependent directly on the p matrix
pftVec  = unique(p.pVeg.PFT);
% AGE    = info.tem.helpers.arrays.zerospixzix.c.cEco; %sujan
for cpN = {'cVegRootF','cVegRootC','cVegWood','cVegLeaf'}
    % get average age from parameters
    AGE    = info.tem.helpers.arrays.zerospix; %sujan
    for ij = 1:numel(pftVec)
        AGE(p.pVeg.PFT == pftVec(ij))    =   p.cCycleBase.([cpN{:} '_AGE_per_PFT'])(pftVec(ij));
    end
    % compute annk based on age
    annk                                =   1e-40 .* info.tem.helpers.arrays.onespix; %sujan ones(size(AGE))
    annk(AGE > 0)                       =   1 ./ AGE(AGE > 0);
    % feed it to the new annual turnover rates
    zix                                 =   info.tem.model.variables.states.c.zix.(cpN{:});
    s.cd.p_cCycleBase_annk(:,zix)       =   annk(:); %sujan
%     s.cd.p_cCycleBase_annk(:,zix)       =   annk(:,zix);
end

% feed the parameters that are pft dependent...
pftVec                                  =   unique(p.pVeg.PFT);
s.cd.p_cTaufpVeg_LITC2N                 =   info.tem.helpers.arrays.zerospix;
s.cd.p_cTaufpVeg_LIGNIN                 =   info.tem.helpers.arrays.zerospix;
for ij = 1:numel(pftVec)
    s.cd.p_cTaufpVeg_LITC2N(p.pVeg.PFT == pftVec(ij))    = p.cTaufpVeg.LITC2N_per_PFT(pftVec(ij));
    s.cd.p_cTaufpVeg_LIGNIN(p.pVeg.PFT == pftVec(ij))    = p.cTaufpVeg.LIGNIN_per_PFT(pftVec(ij));
end

% CALCULATE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
% CALCULATE LIGNIN 2 NITROGEN SCALAR
L2N     = (s.cd.p_cTaufpVeg_LITC2N .* s.cd.p_cTaufpVeg_LIGNIN) .* p.cTaufpVeg.NONSOL2SOLLIGNIN;

% DETERMINE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
MTF                     = p.cTaufpVeg.MTFA - (p.cTaufpVeg.MTFB .* L2N);
MTF(MTF < 0)            = 0;
s.cd.p_cTaufpVeg_MTF    = MTF;

% DETERMINE FRACTION OF C IN STRUCTURAL LITTER POOLS FROM LIGNIN
s.cd.p_cTaufpVeg_SCLIGNIN    = (s.cd.p_cTaufpVeg_LIGNIN .* s.cd.p_cTaufpVeg_C2LIGNIN .* p.cTaufpVeg.NONSOL2SOLLIGNIN) ./ (1 - MTF);

% DETERMINE EFFECT OF LIGNIN CONTENT ON k OF cLitLeafS AND cLitRootFS
s.cd.p_cTaufpVeg_LIGEFF = exp(-p.cTaufpVeg.LIGEFFA .* s.cd.p_cTaufpVeg_SCLIGNIN);

% feed the output
s.cd.p_cTaufpVeg_kfVeg(:,info.tem.model.variables.states.c.zix.cLitLeafS)    = s.cd.p_cTaufpVeg_LIGEFF;
s.cd.p_cTaufpVeg_kfVeg(:,info.tem.model.variables.states.c.zix.cLitRootFS)    = s.cd.p_cTaufpVeg_LIGEFF;


end %function
