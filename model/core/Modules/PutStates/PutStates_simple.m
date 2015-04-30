function [fx,s,d] = PutStates_simple(f,fe,fx,s,d,p,info,i)

% if we make that the default function i'll make it fast in the generated
% code (avoiding the eval) and if and else ...

cvars	= info.variables.rememberState;
for ii = 1:length(cvars)
    cvar	= char(cvars(ii));
    tmp     = splitZstr(cvar,'.');
    if strncmp(cvar,'s.',2) || strncmp(cvar,'d.Temp.',7)
        eval(['d.Temp.p' char(tmp(end)) ' = ' cvar ';'])
    else
        eval(['d.Temp.p' char(tmp(end)) ' = ' cvar '(:,i);'])
    end
end

cvars = info.variables.saveState;
for ii = 1:length(cvars)
    cvar    = char(cvars(ii));
    tmp     = splitZstr(cvar,'.');
    tmpVN   = char(tmp(end));
    if strcmp(tmpVN,'value');
        tmpVN   = [char(tmp(end-1)) '.' char(tmp(end))];
    end
    if strncmp(cvar,'s.',2)
        eval(['d.statesOut.' tmpVN '(:,i) = ' cvar ';'])
    end
end

end % function

