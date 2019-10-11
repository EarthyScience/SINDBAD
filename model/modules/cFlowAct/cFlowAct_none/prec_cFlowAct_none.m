function [f,fe,fx,s,d,p] = prec_cFlowAct_none(f,fe,fx,s,d,p,info)
% @nc : none means there is not transfer, or that nothing is transfered, so, flux matrices are all 0 and figer, taker order is []

tmp	= repmat(info.tem.helpers.arrays.zerospixzix.c.cEco,1,1,...
	info.tem.model.variables.states.c.nZix.cEco);

% get the transfer matrix
s.cd.p_cFlowAct_A       = tmp;
s.cd.p_cFlowAct_E       = tmp;
s.cd.p_cFlowAct_F       = tmp;
% transfers
s.cd.p_cFlowAct_taker	= [];
s.cd.p_cFlowAct_giver   = [];

end %function
