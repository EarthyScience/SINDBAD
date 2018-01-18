function [precs,modules]=ImportPrecsModules(pthModules,ModuleNames,Approaches)

precs=struct;
modules=struct;
%precsGen=struct;

% Pxl=dir([pthPrecsGen '/Prec_Gen*.m']);
% 
% for j=1:length(Pxl);
%     precsGen(j).doAlways=0;
%     [precsGen]=GatherCode([pthPrecsGen Pxl(j).name],precsGen,j);       
% end



cntP=1;
cntM=1;
for i=1:length(ModuleNames)
    cpth=[pthModules char(ModuleNames(i)) filesep];
    
    Pxl=dir([cpth filesep 'Prec_' char(Approaches(i)) '*.m']);
    Mxl=dir([cpth filesep char(Approaches(i)) '*.m']);
    
    
    %Pxl=dir([cpth '/Prec_' char(Approaches(i)) '*.xl*']);
    %Mxl=dir([cpth '/' char(Approaches(i)) '*.xl*']);
    
    for j=1:length(Pxl)
        precs(cntP).doAlways=0;
        %do for Prec
        %get the code and stuff
        [precs]=GatherCode([cpth Pxl(j).name],precs,cntP);
        %xlsfile contents
        %[precs]=GatherXLSfiles([cpth Pxl(j).name],precs,cntP);
        cntP=cntP+1;
    end
    %do for Modules
    for j=1:length(Mxl)
        modules(cntM).doAlways=1;
        %get the code and stuff
        [modules]=GatherCode([cpth Mxl(j).name],modules,cntM);
        %xlsfile contents
        %[modules]=GatherXLSfiles([cpth Mxl(j).name],modules,cntM);
        
        cntM=cntM+1;
    end
end
end