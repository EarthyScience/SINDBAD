function [f,fe,fx,s,d,p] = wBalance_simple(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % check consistency in cCycle matrix: cAlloc, cFlow
    %
    % Inputs:
    %	- s.cd.cAlloc:            carbon allocation matrix
    %   - s.cd.p_cFlowAct_A:      carbon flow matrix  
    %   - p.cCycleBase.fluxOrder: flux order array
    %
    % Outputs:
    %   - 
    %
    % Modifies:
    % 	- 
    %
    % References:
    %	- 
    %
    % Created by:
    %   - Simon Besnard (sbesnard)
    %
    % Versions:
    %   - 1.0 on 12.03.2020
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % check allocation matrix
    tmp0 = s.cd.cAlloc(:); %sujan
    tmp1 = sum(s.cd.cAlloc,2);
    if any(tmp0 > 1) || any(tmp0 < 0)
        error('SINDBAD TEM: cAlloc lt 0 or gt 1')
    end
    if any(abs(sum(tmp1,2)-1) > 1E-6)
        error('SINDBAD TEM: sum(cAlloc) ne 1')
    end

    % check carbon flow on matrix
    flagUp = repmat(reshape(triu(ones(size(s.cd.p_cFlowAct_A)),1),[1 size(p.cCycleBase.cFlowE)]),info.tem.helpers.sizes.nPix,1,1); 
    flagLo = repmat(reshape(tril(ones(size(s.cd.p_cFlowAct_A)),-1),[1 size(p.cCycleBase.cFlowE)]),info.tem.helpers.sizes.nPix,1,1); 
    % Diagonal values of 0 must be between 0 and 1
    anyBad     = any(s.cd.p_cFlowAct_A.*(flagLo+flagUp) < 0);
    if anyBad 
        error('negative values in the cFlowAct_A matrix!')
    end
    anyBad     = any(s.cd.p_cFlowAct_A.*(flagLo+flagUp) > 1);
    if anyBad 
        error('values in the cFlowAct_A matrix greater than 1!')
    end
    % in the lower and upper part of the matrix A the sums have to be lower than 1
    anyBad     = any(sum(s.cd.p_cFlowAct_A.*flagLo,2)>1);
    if anyBad
        error('sum of cols higher than one in lower in the cFlowAct_A!')
    end
    anyBad     = any(sum(s.cd.p_cFlowAct_A.*flagUp,2)>1);
    if anyBad
        error('sum of cols higher than one in upper in the cFlowAct_A')
    end

    % check on flux order check
    if ~isfield(p.cCycleBase,'fluxOrder')
    p.cCycleBase.fluxOrder = 1:numel(taker);
    else
    if numel(p.cCycleBase.fluxOrder) ~= numel(taker)
        error(['ERR : cFlowAct_* : '...
            'numel(p.cCycleBase.fluxOrder) ~= numel(taker)'])
    end
    end
end
