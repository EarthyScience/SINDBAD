function [AllInputs,AllOutputs]=GetAllInputsOutputs(precsGen,precs,modules)

AllInputs=[];
AllOutputs=[];

for i=1:length(precsGen)
    AllInputs=vertcat(AllInputs,precsGen(i).Input);
    AllOutputs=vertcat(AllOutputs,precsGen(i).Output);
end

for i=1:length(precs)
    AllInputs=vertcat(AllInputs,precs(i).Input);
    AllOutputs=vertcat(AllOutputs,precs(i).Output);
end

for i=1:length(modules)
    AllInputs=vertcat(AllInputs,modules(i).Input);
    AllOutputs=vertcat(AllOutputs,modules(i).Output);
end

AllInputs=unique(AllInputs);
AllOutputs=unique(AllOutputs);
end