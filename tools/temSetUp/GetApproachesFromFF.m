function [Approaches]=GetApproachesFromFF(AllApproaches,dFF,dFFindex)
x=dFF(dFFindex,:);
Approaches=cell(1,length(x));
for i=1:length(x)
    Approaches(i)=AllApproaches(i).Name(x(i));
end
end