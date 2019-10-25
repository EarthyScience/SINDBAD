function [f,fe,fx,s,d,p] = dyna_QTotal_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculate total terrestrial water storage
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% wSoil      : soil water [mm]
%           (s.w.wSoil)
% wSWE      : snowpack [mm]
%           (s.w.wSnow)
% wSurf      : surface water storage [mm]
%           (s.w.wSurf)
%
% OUTPUT
% TWS    : terrestrial water storage [mm]
%           (s.w.wTWS)
%
% NOTES:
%
% #########################################################################
% wSoil1 = squeeze(d.storedStates.wSoil(:,1,:));
% wSoil2 = squeeze(d.storedStates.wSoil(:,2,:));

qComps=info.tem.model.variables.to.sum.Q;
fx.Q(:,tix)=0;
for ws = 1:numel(qComps)
    qComp=qComps{ws};
    if isfield(fx,qComp)
        if info.tem.model.flags.genRedMemCode && ismember(qComp,info.tem.model.code.variables.to.redMem)
            fx.Q(:,tix) = fx.Q(:,tix)  + fx.(qComp);
        else
            fx.Q(:,tix) = fx.Q(:,tix)  + fx.(qComp)(:,tix);
        end
    end
end
% qComps=info.tem.model.variables.to.sum.Q;
% qTotal = 0;
% for ws = 1:numel(qComps)
%     qComp=qComps{ws};
%     if isfield(fx,qComp)
%         qContriF = fx.(qComp);
%         if info.tem.model.flags.genRedMemCode && ismember(qComp,info.tem.model.code.variables.to.redMem)
%             qContri=qContriF;
%         else
%             qContri=qContriF(:,tix);
%         end
%         if ~isnan(qContri)
%             qTotal = qTotal  + qContri;
%         end        
%     end
% end
% fx.Q(:,tix)= qTotal ;
end
