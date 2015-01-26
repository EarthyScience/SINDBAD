function [fx,s,d] = PutStates_MJ(f,fe,fx,s,d,p,info,i)

%if we make that the default function i'll make it fast in the generated
%code (avoiding the eval) and if and else ...

%doesn't have the copying of states to d yet ...
cvars = info.variables.rememberState;
for ii=1:length(cvars)
    cvar = char(cvars(ii));
    tmp = strsplit(cvar,'.');
    if strncmp(cvar,'s.',2)
        eval(['d.Temp.p' char(tmp(end)) ' = ' cvar ';'])
    else
        eval(['d.Temp.p' char(tmp(end)) ' = ' cvar '(:,i);'])
    end
    %should be changed to s.!!!!!!
end


end % function

