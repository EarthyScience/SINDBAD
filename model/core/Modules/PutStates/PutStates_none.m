function [fx,s,d] = PutStates_none(f,fe,fx,s,d,p,info,i)

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

% dirty dirty dirty dirty dirty dirty dirty dirty dirty dirty dirty
fx.reco(:,i) = fx.rh(:,i) + fx.ra(:,i);
fx.nee(:,i)	= fx.gpp(:,i) - fx.reco(:,i);

end % function

