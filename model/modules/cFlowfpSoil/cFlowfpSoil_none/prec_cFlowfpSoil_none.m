function [f,fe,fx,s,d,p] = prec_cFlowfpSoil_none(f,fe,fx,s,d,p,info)
% set transfer between pools to 0 (i.e. nothing is transfered)
s.cd.p_cFlowfpSoil_E      =   repmat(info.tem.helpers.arrays.zerospixzix.c.cEco,1,1,...
                                        info.tem.model.variables.states.c.nZix.cEco);
s.cd.p_cFlowfpSoil_F      =   s.cd.p_cFlowfpSoil_E;
end %function
