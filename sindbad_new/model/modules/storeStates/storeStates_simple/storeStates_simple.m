function [fx,s,d] = storeStates_simple(f,fe,fx,s,d,p,info,tix)

% if we make that the default function i'll make it fast in the generated
% code (avoiding the eval) and if and else ...

cvars	= info.variables.rememberState;
for ii = 1:length(cvars)
    cvar	= cvars{ii};
    tmp     = splitZstr(cvar,'.');
    if strncmp(cvar,'s.',2) || strncmp(cvar,'d.tmp.',7)
        eval(['s.prev.' tmp{end} ' = ' cvar ';'])
    else
        eval(['s.prev.' tmp{end} ' = ' cvar '(:,tix);'])
    end
end

cvars = info.variables.saveState;
for ii = 1:length(cvars)
    cvar    = cvars{ii};
    tmp     = splitZstr(cvar,'.');
    tmpVN   = tmp{end};
    if strcmp(tmpVN,'value');
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

