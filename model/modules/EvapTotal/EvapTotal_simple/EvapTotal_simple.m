function [f,fe,fx,s,d,p] = EvapTotal_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculate total evapotranspiration
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% etComps    : evapotranspiration components to sum up
%           (info.tem.model.variables.to.sum.ET)
%
% OUTPUT
% ET         : total evapotranspiration [mm/t]
%           (fx.ET)
% NOTES:
%
% #########################################################################
% etComps={'EvapSoil','EvapInt','EvapSub','Transp'};

etComps=info.tem.model.variables.to.sum.ET;
etTotal = 0;
for ws = 1:numel(etComps)
    etComp=etComps{ws};
    if isfield(fx,etComp)
        etContri = fx.(etComp);
    end
    if ~isnan(etContri)
        etTotal = etTotal  + etContri;
    end
end
fx.ET = etTotal;

%% previous:
% etComps=info.tem.model.variables.to.sum.ET;
% 
% etTotal = 0;
% for ws = 1:numel(etComps)
%     etComp=etComps{ws};
%     if isfield(fx,etComp)
%         etContriF = fx.(etComp);
%         if info.tem.model.flags.genRedMemCode && ismember(etComp,info.tem.model.code.variables.to.redMem)
%             etContri=etContriF;
%         else
%             etContri=etContriF(:,tix);
%         end
%     end
%     if ~isnan(etContri)
%         etTotal = etTotal  + etContri;
%     end
%     
% end
% fx.ET(:,tix) = etTotal ;
% end
