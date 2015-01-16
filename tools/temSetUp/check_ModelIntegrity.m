function [IsCompatible]=check_ModelIntegrity(info)

%Compatibilty is here simply assessed by checking if all inputs from
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
    
    error('Model Structure Error: Mismatch of Inputs and Ouputs')
    
end
%setdiff(AllInputs,AllOutputs)
end