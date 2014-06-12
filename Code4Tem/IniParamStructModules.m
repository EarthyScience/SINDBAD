function [p]=IniParamStructModules(precs,modules);
p=struct;
for i=1:length(precs)
    for j=1:length(precs(i).params.Name)
        
        eval(['p.' char(precs(i).params.Name(j)) '=' num2str(precs(i).params.Default(j)) ';']);
        
    end
end

for i=1:length(modules)
    for j=1:length(modules(i).params.Name)
        
        eval(['p.' char(modules(i).params.Name(j)) '=' num2str(modules(i).params.Default(j)) ';']);
        
    end
end
end