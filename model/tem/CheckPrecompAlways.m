function [precs]=CheckPrecompAlways(precs,paramsOpt);

%loop from top to bottom
for i=1:length(precs)
    %if input is a param that is optimised --> flag (precomp always)
    
    %a= ismember(precs(i).params.Names,paramsOpt);
    if ~isempty(precs(i).funInput)
        a= ismember(precs(i).funInput,paramsOpt);
        if sum(a)>0
            precs(i).DoAlways=1;
            
            %check if any other prec down in the sequence requires an input which
            %is the output of this prec; if so --> flag for DEPENDENT prec (precomp always)
            for j=i+1:length(precs)
                if ~isempty(precs(j).funInput)
                    a= ismember(precs(j).funInput,precs(i).funOutput);
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