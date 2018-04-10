function [fx,s,d] = storeStates_none(f,fe,fx,s,d,p,info,tix)

cvars = info.variables.saveState;
for ii = 1:length(cvars)
    cvar    = cvars{ii};
    tmp     = splitZstr(cvar,'.');
    tmpVN   = tmp{end};
    if strcmp(tmpVN,'value')
        tmpVN   = [tmp{end-1} '.' tmp{end}];
    end
    if strncmp(cvar,'s.',2)
        eval(['d.statesOut.' tmpVN '(:,tix) = ' cvar ';'])
    end
end

% dirty dirty dirty dirty dirty dirty dirty dirty dirty dirty dirty
fx.reco(:,tix) = fx.rh(:,tix) + fx.ra(:,tix);
fx.nee(:,tix)	= fx.gpp(:,tix) - fx.reco(:,tix);

end % function

