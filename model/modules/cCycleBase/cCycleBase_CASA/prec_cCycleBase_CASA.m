function [f,fe,fx,s,d,p] = prec_cCycleBase_CASA(f,fe,fx,s,d,p,info)
s.cd.p_cCycleBase_annk = reshape(repelem(p.cCycleBase.annk,info.tem.helpers.sizes.nPix),info.tem.helpers.sizes.nPix,info.tem.model.variables.states.c.nZix.cEco); %sujan
% s.cd.p_cCycleBase_annk=p.cCycleBase.annk;
end %function 