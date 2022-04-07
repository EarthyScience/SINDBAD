function [f,fe,fx,s,d,p] = prec_cFlowAct_none(f,fe,fx,s,d,p,info)
% set transfer between pools to 0 (i.e. nothing is transfered)
% set giver and taker matrices to []
tmp    = repmat(info.tem.helpers.arrays.zerospixzix.c.cEco,1,1,...
    info.tem.model.variables.states.c.nZix.cEco);

% get the transfer matrix
s.cd.p_cFlowAct_A       = tmp;
s.cd.p_cFlowAct_E       = tmp;
s.cd.p_cFlowAct_F       = tmp;
% transfers
s.cd.p_cFlowAct_taker    = [];
s.cd.p_cFlowAct_giver   = [];
end %function
