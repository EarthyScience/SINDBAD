function [f,fe,fx,s,d,p] = QTotal_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculate total runoff
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% qComps    : runoff components to sum up
%           (info.tem.model.variables.to.sum.Q)
%
% OUTPUT
% Q         : total runoff [mm/t]
%           (fx.Q)
%
% NOTES:
%
% #########################################################################

qComps = info.tem.model.variables.to.sum.Q;
qTotal = 0;
for ws = 1:numel(qComps)
    qComp=qComps{ws};
    if isfield(fx,qComp)
        qContri = fx.(qComp);
        if ~isnan(qContri)
            qTotal = qTotal  + qContri;
        end
    end
end
fx.Q = qTotal ;

%% previous:
% qComps=p.Qtotal.components;
% % qComps={'Qb','QsurfIndir','QsurfDir'};
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
