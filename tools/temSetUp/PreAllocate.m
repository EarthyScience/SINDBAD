function [fx,fe,d]=PreAllocate(info)

AllVars=info.variables.all;

sstr={'d.','fe.','fx.'};

d=struct;
fe=struct;
fx=struct;

tmp=NaN(info.forcing.size);
tmp2=NaN(info.forcing.size(1),1);

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



end