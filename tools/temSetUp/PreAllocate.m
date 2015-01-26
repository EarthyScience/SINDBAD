function [fx,fe,d]=PreAllocate(info)

AllVars=info.variables.all;

sstr={'d.','fe.','fx.'};

d=struct;
fe=struct;
fx=struct;

tmp=NaN(info.forcing.size);

%loop over d, fe, fx
for ii=1:length(sstr)
    
    csstr=char(sstr(ii));
    
    %find respective variables
    v=find(strncmp(AllVars,csstr,length(csstr)));
    %loop over respective variables
    for jj=1:length(v)
        
        eval([char(AllVars(v(jj))) '=tmp;'])
        
    end
    
end



end