function [precs]=GetInputOutputFromCode(precs)


sstr={'p\.\w*\.\w*','d\.\w*\.\w*','f\.\w*','fe\.\w*','fx\.\w*','s\.\w*'};

for i=1:length(precs)
    Output={[]};
    Input={[]};
    cntI=1;
    cntO=1;
    
    [starteq] =regexp(precs(i).funCont,'=');
    for j=1:length(sstr)
        
        [matchstart,matchend,tokenindices,matchstring,tokenstring, tokenname,splitstring] =regexp(precs(i).funCont,sstr(j));
        
        v=find(cellfun(@isempty,matchstart)==0);
        for k=1:length(v)
            cv=v(k);
            cl=length(matchstart{cv});
            cmstart=matchstart{cv};
            ceq=starteq{cv};
            cstring=matchstring{cv};
            for l=1:cl
                if cmstart(l) < ceq
                    %is output
                    Output(cntO,1)=cstring(l);
                    cntO=cntO+1;
                else
                    Input(cntI,1)=cstring(l);
                    cntI=cntI+1;
                    %is input
                    
                end
            end
            
        end
        
    end
    if ~isempty(Input{1})
        precs(i).funInput=unique(Input);
    end
    if ~isempty(Output{1})
        precs(i).funOutput=unique(Output);
    end
    
end

end
