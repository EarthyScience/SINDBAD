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
    s.cd.p_cFlowAct_A = repmat(reshape(p.cCycleBase.cFlowA, [1 size(p.cCycleBase.cFlowA)]), info.tem.helpers.sizes.nPix, 1, 1);

    % transfers
    [taker, giver] = find(squeeze(sum(s.cd.p_cFlowAct_A > 0, 1)) >= 1);
    s.cd.p_cFlowAct_taker = taker;
    s.cd.p_cFlowAct_giver = giver;

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
