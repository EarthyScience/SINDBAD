function [fx,s,d] = core_expCodeGen01(f,fe,fx,s,d,p,info);
for i=1:info.forcing.size(2)
d.Temp.WBP  = f.Rain(:,i);
s.wSWE = info.helper.zeros1d;
s.wGW = info.helper.zeros1d;
fx.ESoil    = info.helper.zeros2d;
s.wSM       = info.helper.zeros1d;
fx.gpp = info.helper.zeros2d;
fx.Transp = info.helper.zeros2d;
s.wGWR = info.helper.zeros1d;
fx.ra = info.helper.zeros2d;
fx.rh = info.helper.zeros2d;
cvars = info.variables.saveState;
for ii = 1:length(cvars)
cvar    = cvars{ii};
tmp     = splitZstr(cvar,'.');
tmpVN   = tmp{end};
if strcmp(tmpVN,'value')
tmpVN   = [tmp{end-1} '.' tmp{end}];
end
if strncmp(cvar,'s.',2)
eval(['d.statesOut.' tmpVN '(:,i) = ' cvar ';'])
end
end
fx.reco(:,i) = fx.rh(:,i) + fx.ra(:,i);
fx.nee(:,i)	= fx.gpp(:,i) - fx.reco(:,i);
end
end
