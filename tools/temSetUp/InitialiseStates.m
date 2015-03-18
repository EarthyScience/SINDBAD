function [s]=InitialiseStates(info,p,forcingSize)

%forcingSize [nspace ntime]; usually info.forcing.size

AllVars=info.variables.all;

csstr='s.';

s=struct;

tmp0=zeros(forcingSize(1),1);

%find respective variables
v=find(strncmp(AllVars,csstr,length(csstr)));
%loop over respective variables
for jj=1:length(v)
    
    cname=char(AllVars(v(jj)));
    
    switch cname
        case 's.wSM1'
            s.wSM1=p.SOIL.AWC1;
            
        case 's.wSM2'
            s.wSM2=p.SOIL.AWC2;
            
        case 's.wSWE'
            s.wSWE=tmp0;
            
        case 's.wWTD'  
            s.wWTD=tmp0;
            
        case 's.wGW'
            s.wGW=tmp0;
            
        case 's.wGWR'
            s.wGWR=tmp0;
            
            
    end
    
end





end