function [precsGen,precs]=CheckPrecompAlways(precsGen,precs,paramsOpt);


%loop from top to bottom
for i=1:length(precsGen)
    %if input is a param that is optimised --> flag (precomp always)
    
    %a= ismember(precsGen(i).params.Names,paramsOpt);
    a= ismember(precsGen(i).Input,paramsOpt);
    if sum(a)>0
        precsGen(i).DoAlways=1;
        
        %check if any other prec down in the sequence requires an input which
        %is the output of this prec; if so --> flag for DEPENDENT prec (precomp always)
        for j=i+1:length(precsGen)
            if ~isempty(precsGen(j).Input)
                a= ismember(precsGen(j).Input,precsGen(i).Output);
                if sum(a)>0
                    precsGen(j).DoAlways=1;
                end
            end
        end
        
        %now additionally loop over precs
        for j=1:length(precs)
            if ~isempty(precs(j).Input)
                a= ismember(precs(j).Input,precsGen(i).Output);
                if sum(a)>0
                    precs(j).DoAlways=1;
                end
            end
        end
        
        
    end
    
    %find all precs where and input from d,fx,fe is their output
    %if in any of them an optimised param --> flag (precomp always)
end






%loop from top to bottom
for i=1:length(precs)
    %if input is a param that is optimised --> flag (precomp always)
    
    %a= ismember(precs(i).params.Names,paramsOpt);
    if ~isempty(precs(i).Input)
        a= ismember(precs(i).Input,paramsOpt);
        if sum(a)>0
            precs(i).DoAlways=1;
            
            %check if any other prec down in the sequence requires an input which
            %is the output of this prec; if so --> flag for DEPENDENT prec (precomp always)
            for j=i+1:length(precs)
                if ~isempty(precs(j).Input)
                    a= ismember(precs(j).Input,precs(i).Output);
                    if sum(a)>0
                        precs(j).DoAlways=1;
                    end
                end
            end
        end
    end
    %find all precs where and input from d,fx,fe is their output
    %if in any of them an optimised param --> flag (precomp always)
end

end