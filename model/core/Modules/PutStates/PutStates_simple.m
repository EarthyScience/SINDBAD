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
    if strncmp(cvar,'s.',2) && strcmpi(cvar(3),'c') && ~strncmp(cvar,'s.cPools',8)
        poolname                    = cvar(3:end);
        x                           = CMIP5cPools(info,s,poolname);
        d.statesOut.(tmpVN)(:,i)    = x;
    elseif strncmp(cvar,'s.',2)
        eval(['d.statesOut.' tmpVN '(:,i) = ' cvar ';'])
    end
end

% water pools
d.Temp.pwSM	    = s.wSM;
d.Temp.pwGW     = s.wGW;
d.Temp.pwGWR    = s.wGWR;
d.Temp.pwSWE    = s.wSWE;
%d.Temp.pwWTD    = s.wWTD;


d.Temp.pSMScGPP = d.SMEffectGPP.SMScGPP(:,i);

end % function

