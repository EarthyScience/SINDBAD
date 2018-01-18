function [AllInputs,AllOutputs]=GetAllInputsOutputs(precs,modules)

AllInputs=[];
AllOutputs=[];

%%%
for i=1:length(precs)
    AllInputs=vertcat(AllInputs,precs(i).funInput);
    AllOutputs=vertcat(AllOutputs,precs(i).funOutput);
end

for i=1:length(modules)
    AllInputs=vertcat(AllInputs,modules(i).funInput);
    AllOutputs=vertcat(AllOutputs,modules(i).funOutput);
end

AllInputs=unique(AllInputs);
AllOutputs=unique(AllOutputs);
end