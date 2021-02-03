function [f,fe,fx,s,d,p] = prec_cFlowAct_gsi(f,fe,fx,s,d,p,info)
    % see dyna_cFlowAct_gsi
    % Do A matrix
    s.cd.p_cFlowAct_A               = repmat(reshape(p.cCycleBase.cFlowA, [1 size(p.cCycleBase.cFlowA)]), info.tem.helpers.sizes.nPix, 1, 1);


        % Adjust cFlow between reserve, leaf, root, and soil
        aM = {...
        'cVegReserve',  'cVegLeaf',    1; ...
        'cVegReserve',  'cVegRoot',    1; ...
        'cVegLeaf',     'cVegReserve', 1; ...
        'cVegRoot',     'cVegReserve', 1; ...
        'cVegLeaf',     'cSoil',       1; ... 
        'cVegRoot',     'cSoil',       1; ... 
        };

    for ii = 1:size(aM, 1)
        ndxSrc = info.tem.model.variables.states.c.zix.(aM{ii, 1});
        ndxTrg = info.tem.model.variables.states.c.zix.(aM{ii, 2}); 

        for iSrc = 1:numel(ndxSrc)

            for iTrg = 1:numel(ndxTrg)
                s.cd.p_cFlowAct_A(:, ndxTrg(iTrg), ndxSrc(iSrc)) = aM{ii, 3};
            end
        end
    end

    % transfers
    [taker, giver] = find(squeeze(sum(s.cd.p_cFlowAct_A > 0, 1)) >= 1);
    s.cd.p_cFlowAct_taker = taker;
    s.cd.p_cFlowAct_giver = giver;

    % if there is flux order check that is consistent
    if ~isfield(p.cCycleBase,'fluxOrder')
        p.cCycleBase.fluxOrder = 1:numel(taker);
    else
        if numel(p.cCycleBase.fluxOrder) ~= numel(taker)
            error(['ERR : cFlowAct_gsi : '...
                'numel(p.cCycleBase.fluxOrder) ~= numel(taker)'])
        end
    end


end %function
