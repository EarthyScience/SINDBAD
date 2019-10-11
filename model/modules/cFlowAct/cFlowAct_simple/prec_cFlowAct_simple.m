function [f,fe,fx,s,d,p] = prec_cFlowAct_simple(f,fe,fx,s,d,p,info)
% combine all the effects that change the transfers between carbon pools...

%@nc : this needs to go in the full...

% outputs 
% s.cd.p_cFlowAct_A

% jus the A matrix...
s.cd.p_cFlowAct_A                 = repmat(reshape(p.cCycleBase.cFlowA,[1 size(p.cCycleBase.cFlowA)]),info.tem.helpers.sizes.nPix,1,1); 

% @nc : here we should check that: 
%	the sum of F per column below the diagonals are always == 1 
%	
%	the sum of E per column below the diagonals are always < 1 
%	the sum of E per column above the diagonals are always < 1 
%
%	the sum of A per column below the diagonals are always < 1 
%	the sum of A per column above the diagonals are always < 1 

% transfers
[taker,giver]           = find(squeeze(sum(s.cd.p_cFlowAct_A > 0,1)) >= 1);
s.cd.p_cFlowAct_taker	= taker;
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
