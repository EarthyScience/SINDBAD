function [IsCompatible]=check_ModelIntegrity(info)

%Compatibility is here simply assessed by checking if all inputs from
%fe,fx,d,s are also some output of the same or another function (order of
%computations is not checked);



AllInputs=info.variables.input;
AllOutputs=info.variables.output;

%get rid of the ones that start with 'p.','f.'
k=strfind(AllInputs,'p.');
kk=strfind(AllInputs,'f.');
tf=cellfun(@isempty,k) & cellfun(@isempty,kk);
AllInputs=AllInputs(tf);

k=strfind(AllOutputs,'p.');
kk=strfind(AllOutputs,'f.');
tf=cellfun(@isempty,k) & cellfun(@isempty,kk);
AllOutputs=AllOutputs(tf);

% to debug: setdiff(AllInputs,AllOutputs) ;)



[c,ia,ib]=intersect(AllInputs,AllOutputs);
if length(c)==length(AllInputs)
    IsCompatible=1;
else
    IsCompatible=0;
    
    
    ProblemVars=setdiff(AllInputs,AllOutputs);
    %IsIn=false(length(ProblemVars),1);
    modules=fieldnames(info.code.ms);
    
    for ii=1:length(ProblemVars)
        tmp=strcmp(ProblemVars(ii),AllInputs);
        if sum(tmp)>0
            %IsIn(ii)=1;
            %is an input
            
            for iii=1:length(modules)
                eval(['tmp2=strcmp(ProblemVars(ii),info.code.ms.' char(modules(iii)) '.funInput);'])
                if sum(tmp2)>0
                    disp([ProblemVars{ii} ' is input to ' modules{iii} ' but is no output'])
                end
            end
            
            %precomps
            for iii=1:length(info.code.preComp)
                tmp2=strcmp(ProblemVars(ii),info.code.preComp(iii).funInput);
                if sum(tmp2)>0
                    disp([ProblemVars{ii} ' is input to ' info.code.preComp(iii).funName{1} ' but is no output'])
                end
                
            end
            
        else
            %is an output
            for iii=1:length(modules)
                eval(['tmp2=strcmp(ProblemVars(ii),info.code.ms.' modules{iii} '.funOutput);'])
                if sum(tmp2)>0
                    disp([ProblemVars{ii} ' is output of ' modules{iii} ' but is no input'])
                end
            end
            
             %precomps
            for iii=1:length(info.code.preComp)
                tmp2=strcmp(ProblemVars(ii),info.code.preComp(iii).funOutput);
                if sum(tmp2)>0
                    disp([ProblemVars{ii} ' is output of ' info.code.preComp(iii).funName{1} ' but is no input'])
                end
                
            end
            
        end
        
        
    end
    
    
    
    %error('Model Structure Error: Mismatch of Inputs and Ouputs')
    warning('Model Structure Error: Mismatch of Inputs and Ouputs')
    
end
%setdiff(AllInputs,AllOutputs)
end