function [AllApproaches,nlevels,dFF]=InventorizeApproaches(pthCore)

%inventorise approaches
AllApproaches=struct;

[ModuleNames]=GetModuleNamesFromCore(pthCore);
nlevels=zeros(1,length(ModuleNames));

for i=1:length(ModuleNames);
    cpth=[pthModules char(ModuleNames(i)) '/'];
        
    Mxl=dir([cpth '/' char(ModuleNames(i)) '*.m']);
    
    AllApproaches(i).Name={Mxl.name};
    nlevels(i)=length(AllApproaches(i).Name);
end

dFF = fullfact(nlevels);

end