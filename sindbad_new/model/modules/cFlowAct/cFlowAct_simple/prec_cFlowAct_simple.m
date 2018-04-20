function [fe,fx,d,p,f] = prec_cFlowAct_simple(f,fe,fx,s,d,p,info,tix)
% combine all the effects that change the transfer matrix

% combine the soil and the veg scalars
ceff 	= zeros(size(p.cCycleBase.cTransfer));
ndx		= s.cd.p_cFlowfpSoil_fSoil > 0 & s.cd.p_cFlowfpVeg_fVeg > 0;
if~isempty(ndx)
	ceff(ndx)= s.cd.p_cFlowfpSoil_fSoil(ndx).*s.cd.p_cFlowfpVeg_fVeg(ndx);
end
% combine the soil and the ~veg scalars
ndx		= s.cd.p_cFlowfpSoil_fSoil > 0 & s.cd.p_cFlowfpVeg_fVeg <= 0;
if~isempty(ndx)
	ceff(ndx)= s.cd.p_cFlowfpSoil_fSoil(ndx);
end
% combine the ~soil and the veg scalars
ndx		= s.cd.p_cFlowfpSoil_fSoil <= 0 & s.cd.p_cFlowfpVeg_fVeg > 0;
if~isempty(ndx)
	ceff(ndx)= s.cd.p_cFlowfpVeg_fVeg(ndx);
end
% combine the transfer with the pre-combined scalars
s.cd.p_cFlowAct_cTransfer = p.cCycleBase.cTransfer;
ndx = p.cCycleBase.cTransfer > 0 & ceff > 0;
if~isempty(ndx)
	s.cd.p_cFlowAct_cTransfer(ndx) = s.cd.p_cFlowAct_cTransfer(ndx) .* ceff(ndx);
end
% combine the ~transfer with the pre-combined scalars
ndx = s.cd.p_cFlowAct_cTransfer <= 0 & ceff > 0;
if~isempty(ndx)
	s.cd.p_cFlowAct_cTransfer(ndx) = ceff(ndx);
end
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



end %function
