function [info]=GetVariablesToRemember(info)

AllVars=info.variables.all; 

DoRemember=false(length(AllVars),1);

AllVarsShort=AllVars;

for ii=1:length(AllVars)
    cvar=char(AllVars(ii));
    
    if ~strncmp(cvar,'p.',2)
    %only keep the last bit
    tmp = splitZstr(cvar,'.');
    AllVarsShort(ii)=cellstr(tmp(end));

    end
end

%the rule is if there is a variable in AllVarsShort which also exists if
%you add a 'p' at the beginning you should remember it

%now check if you find
for ii=1:length(AllVarsShort)
    cvar=char(AllVarsShort(ii));
    
    tf=strcmp(['p' cvar],AllVarsShort);
    
    if sum(tf) > 0 
        DoRemember(ii)=1;
    end
end


info.variables.rememberState=AllVars(DoRemember);

end