function [fx,fe,d]=PreAllocate(info,forcingSize)

%forcingSize [nspace ntime]; usually info.forcing.size

AllVars=info.variables.all;

sstr={'d.','fe.','fx.'};

d=struct;
fe=struct;
fx=struct;

tmp=NaN(forcingSize);
tmp2=NaN(forcingSize(1),1);



%loop over d, fe, fx
for ii=1:length(sstr)
    
    csstr=char(sstr(ii));
    
    %find respective variables
    v=find(strncmp(AllVars,csstr,length(csstr)));
    %loop over respective variables
    for jj=1:length(v)
        
        cVar=char(AllVars(v(jj)));
        
        if strncmp(cVar,'d.Temp',length('d.Temp'))
            eval([cVar ' = tmp2;'])
        else
            eval([cVar ' = tmp;'])
        end
    end
    
end

%preallocate d.statesOut.
cvars = info.variables.saveState;

for ii=1:length(cvars)
    cvar = char(cvars(ii));
    tmp = strsplit(cvar,'.');
    if strncmp(cvar,'s.',2) 
        eval(['d.statesOut.' char(tmp(end)) '(:,i) = tmp;'])
    end    
end



end