function [fx,s,d] = PutStates_AggcPools(f,fe,fx,s,d,p,info,i)


[fx,s,d] = PutStates_simple(f,fe,fx,s,d,p,info,i);

cvars = info.variables.saveState;
for ii = 1:length(cvars)
    cvar    = cvars{ii};
    tmp     = splitZstr(cvar,'.');
    tmpVN   = tmp{end};
    if strncmp(cvar,'s.',2) && strcmpi(cvar(3),'c') && ~strncmp(cvar(3:end),'cPools',6)
        poolname                    = cvar(3:end);
        x                           = CMIP5cPools(info,s,poolname);
        d.statesOut.(tmpVN)(:,i)    = x;
    end
end

end % function

