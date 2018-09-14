function [f,fe,fx,s,d,p] = prec_cFlowfpSoil_none(f,fe,fx,s,d,p,info)
s.cd.p_cFlowfpSoil_E      =   repmat(info.tem.helpers.arrays.zerospixzix.c.cEco,1,1,...
                                        info.tem.model.variables.states.c.nZix.cEco);
s.cd.p_cFlowfpSoil_F      =   s.cd.p_cFlowfpSoil_E;
end %function
