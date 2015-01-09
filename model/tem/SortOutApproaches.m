function [info]=SortOutApproaches(info,ModuleNames,DefaultApproaches,NonDefaultApproaches)

%split into module and approach
[splitDA] =regexp(DefaultApproaches,'\_','split');
[splitA] =regexp(NonDefaultApproaches,'\_','split');

Approaches=ModuleNames;
%this just orders the default approaches (just in case)

for i=1:length(DefaultApproaches)    
    tf=strcmp(splitDA{i}(1),ModuleNames);
    Approaches(tf)=DefaultApproaches(i);    
end

%this overwrites the defaults
for i=1:length(NonDefaultApproaches)    
    tf=strcmp(splitA{i}(1),ModuleNames);
    Approaches(tf)=NonDefaultApproaches(i);    
end

info.Approaches=Approaches;

end
