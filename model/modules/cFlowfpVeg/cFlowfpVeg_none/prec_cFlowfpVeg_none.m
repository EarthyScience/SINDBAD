function [f,fe,fx,s,d,p] = prec_cFlowfpVeg_none(f,fe,fx,s,d,p,info)
s.cd.p_cFlowfpVeg_F      =   repmat(info.tem.helpers.arrays.zerospixzix.c.cEco,1,1,...
                                        info.tem.model.variables.states.c.nZix.cEco);

end %function
