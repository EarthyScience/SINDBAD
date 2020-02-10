function [f,fe,fx,s,d,p] = prec_cCycleBase_CASA(f,fe,fx,s,d,p,info)
%carbon to nitrogen ratio (gC.gN-1)
s.cd.p_cCycleBase_C2Nveg        =   zeros(info.tem.helpers.sizes.nPix,numel(info.tem.model.variables.states.c.zix.cVeg)); %sujan
for zix = info.tem.model.variables.states.c.zix.cVeg
    s.cd.p_cCycleBase_C2Nveg(:,zix)    =   p.cCycleBase.C2Nveg(zix);
end

% annual turnover rates
s.cd.p_cCycleBase_annk = reshape(repelem(p.cCycleBase.annk,info.tem.helpers.sizes.nPix),info.tem.helpers.sizes.nPix,info.tem.model.variables.states.c.nZix.cEco); %sujan

end %function 