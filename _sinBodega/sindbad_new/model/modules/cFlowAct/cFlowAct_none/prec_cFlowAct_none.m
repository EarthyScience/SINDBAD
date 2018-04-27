function [f,fe,fx,s,d,p] = prec_cFlowAct_none(f,fe,fx,s,d,p,info)

if isfield(p,'cCycleBase')
	% combine the transfer with the pre-combined scalars
	s.cd.p_cFlowAct_cTransfer = p.cCycleBase.cTransfer;
    % transfers
    [taker,giver]           = find(s.cd.p_cFlowAct_cTransfer > 0);
    s.cd.p_cFlowAct_taker	= taker;
    s.cd.p_cFlowAct_giver   = giver;
    % if there is flux order check that is consistent
	if ~isfield(p.cCycleBase,'fluxOrder')
		p.cCycleBase.fluxOrder = 1:numel(taker);
	else
		if numel(p.cCycleBase.fluxOrder)~=numel(taker)
			error(['ERR : cFlowAct_simple : '...
				'numel(p.cCycleBase.fluxOrder)~=numel(taker)'])
		end
	end
end

end %function
