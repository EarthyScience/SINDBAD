function [fe,fx,d,p,f] = cFlowAct_simple(f,fe,fx,s,d,p,info,tix)
% combine all the effects that change the transfer matrix

% combine the soil and the veg scalars
ceff 	= zeros(size(p.cCycleBase.cTransfer));
ndx		= p.cFlowfpSoil.fSoil > 0 & p.cFlowfpSoil.fVeg > 0;
if~isempty(ndx)
	ceff(ndx)= p.cFlowfpSoil.fSoil(ndx).*p.cFlowfpSoil.fVeg(ndx);
end
% combine the soil and the ~veg scalars
ndx		= p.cFlowfpSoil.fSoil > 0 & p.cFlowfpSoil.fVeg <= 0;
if~isempty(ndx)
	ceff(ndx)= p.cFlowfpSoil.fSoil(ndx);
end
% combine the ~soil and the veg scalars
ndx		= p.cFlowfpSoil.fSoil <= 0 & p.cFlowfpSoil.fVeg > 0;
if~isempty(ndx)
	ceff(ndx)= p.cFlowfpSoil.fVeg(ndx);
end
% combine the transfer with the pre-combined scalars
ndx = p.cCycleBase.cTransfer > 0 & ceff > 0;
if~isempty(ndx)
	p.cCycleBase.cTransfer(ndx) = p.cCycleBase.cTransfer(ndx) .* ceff(ndx);
end
% combine the ~transfer with the pre-combined scalars
ndx = p.cCycleBase.cTransfer <= 0 & ceff > 0;
if~isempty(ndx)
	p.cCycleBase.cTransfer(ndx) = ceff(ndx);
end

[taker,giver]       = find(p.cCycleBase.cTransfer > 0);
p.cFlowAct.taker	= taker;
p.cFlowAct.giver    = giver;

if ~isfield(p.cCycleBase,'fluxOrder')
    p.cCycleBase.fluxOrder = 1:numel(taker);
else
    if numel(p.cCycleBase.fluxOrder)~=numel(taker)
        error(['ERR : cFlowAct_simple : '...
            'numel(p.cCycleBase.fluxOrder)~=numel(taker)'])
    end
end



end %function
