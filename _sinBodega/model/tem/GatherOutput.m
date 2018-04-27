function [f_o,fe_o,fx_o,s_o,d_o,p_o]=GatherOutput(f,fe,fx,s,d,p,SBvariablesSave)

if strcmpi('all',SBvariablesSave(1))
    f_o=f;
    fe_o=fe;
    fx_o=fx;
    s_o=s;
    d_o=d;
    p_o=p;
    
else               
    
    f_o=struct;
    fe_o=struct;
    fx_o=struct;
    s_o=struct;
    d_o=struct;
    p_o=struct;
    
    for i=1:length(SBvariablesSave)
        cstr=SBvariablesSave{i};
        
        %find the first'.'
        a=strfind(cstr,'.');
        a=a(1);
        cstr2=[cstr(1:a-1) '_o' cstr(a:end)];
        eval([cstr2 '=' cstr ';']);
        
    end
    
end


end