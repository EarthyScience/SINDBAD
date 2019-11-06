function [f,fe,fx,s,d,p] = wTotal_simple(f,fe,fx,s,d,p,info,tix)
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
% NOTES: the functions directly acesses d.storedStates and can only sum up
% TWS components that are in variables.to.keep
%
%
%%
tf=startsWith(info.tem.model.code.variables.moduleAll,'s.w.');
wStorages=info.tem.model.code.variables.moduleAll(tf);

% wStorages=info.tem.model.variables.states.w.names;
wTotal = 0;
for ws = 1:numel(wStorages)
   % wComp=wStorages{ws};
    tmp=split(wStorages{ws},'.');
    wComp=tmp{end};
%     if isfield(s.w,wComp)
%         if info.tem.model.variables.states.w.nZix.(wComp) > 1
            sComp= sum(s.w.(wComp),2);
%         else
%             sComp = s.w.(wComp);
%         end
%     end
    s.wd.([wComp 'Tot']) = sComp ; 

    wTotal = wTotal + sComp;
    
end
s.wd.wTWS = wTotal; 
dTWS=s.wd.wTWS-s.prev.s_wd_wTWS;
s.wd.dTWS=dTWS;
%s.prev.s_wd_wTWS = wTotal;
% s.wd.totalW.wTWS = sum(s.w.wSoil,2) + s.w.wSurf;



end
