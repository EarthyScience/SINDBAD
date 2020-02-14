function [f,fe,fx,s,d,p] = prec_cFlowAct_simple(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % combine all the effects that change the transfers 
    % between carbon pools
    %
    % Inputs:
    %   - p.cCycleBase.cFlowA:     transfer matrix for carbon at ecosystem level
    %
    % Outputs:
    %   - s.cd.p_cFlowAct_A:       effect of vegetation and vegetation on actual transfer rates between pools
    %
    % Modifies:
    %   - s.cd.p_cFlowAct_A
    %
    % References:
    %   - 
    %
    % Created by:
    %   - ncarvalhais 
    %
    % Versions:
    %   - 1.0 on 13.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%@nc : this needs to go in the full...

% Do A matrix...
s.cd.p_cFlowAct_A                 = repmat(reshape(p.cCycleBase.cFlowA,[1 size(p.cCycleBase.cFlowA)]),info.tem.helpers.sizes.nPix,1,1); 

% check on matrix
flagUp = repmat(reshape(triu(ones(size(p.cCycleBase.cFlowA)),1),[1 size(p.cCycleBase.cFlowA)]),info.tem.helpers.sizes.nPix,1,1); 
flagLo = repmat(reshape(tril(ones(size(p.cCycleBase.cFlowA)),-1),[1 size(p.cCycleBase.cFlowA)]),info.tem.helpers.sizes.nPix,1,1); 
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
