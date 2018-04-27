function [IsCompatible]=check_ModelIntegrity(precsGen,precs,modules)

%Compatibilty is here simply assessed by checking if all inputs from
%fe,fx,d,s are also some output of the same or another function (order of
%computations is not checked);

[AllInputs,AllOutputs]=GetAllInputsOutputs(precsGen,precs,modules);

%get rid of the ones that start with 'p.','f.'
k=strfind(AllInputs,'p.');
kk=strfind(AllInputs,'f.');
tf=cellfun(@isempty,k) & cellfun(@isempty,kk);
AllInputs=AllInputs(tf);

k=strfind(AllOutputs,'p.');
kk=strfind(AllOutputs,'f.');
tf=cellfun(@isempty,k) & cellfun(@isempty,kk);
AllOutputs=AllOutputs(tf);

[c,ia,ib]=intersect(AllInputs,AllOutputs);
if length(c)==length(AllInputs)
    IsCompatible=1;
else
    IsCompatible=0;
end
%setdiff(AllInputs,AllOutputs)
end