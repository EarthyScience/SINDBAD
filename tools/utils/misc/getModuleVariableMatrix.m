function [ModuleVariableMatrix,moduleNames,variableNames] = getModuleVariableMatrix(info)

varsConfig = vertcat(info.tem.model.variables.forcingInput(:),info.tem.model.variables.paramInput(:));
variableNames = unique(vertcat(varsConfig(:),info.tem.model.code.variables.moduleAll(:)));
nvars=length(variableNames);

nprecs=length(info.tem.model.code.prec);
moduleNamesAll=fieldnames(info.tem.model.code.ms);

ModuleVariableMatrix=zeros(1,nvars);

moduleNames={'read'};

[c,ia,ib]=intersect(variableNames,varsConfig);
ModuleVariableMatrix(1,ia)=ModuleVariableMatrix(1,ia)+2;

cnt=2;
for ii=1:nprecs
    ModuleVariableMatrix(cnt,:)=0;
    varsIn=info.tem.model.code.prec(ii).funInput;
    varsOut=info.tem.model.code.prec(ii).funOutput;
    
    [c,ia,ib]=intersect(variableNames,varsIn);
    ModuleVariableMatrix(cnt,ia)=1;
    
    [c,ia,ib]=intersect(variableNames,varsOut);
    ModuleVariableMatrix(cnt,ia)=ModuleVariableMatrix(cnt,ia)+2;
    
    moduleNames(cnt)=cellstr(['pre-' info.tem.model.code.prec(ii).moduleName]);
    cnt=cnt+1;
end

for ii=1:length(moduleNamesAll)
    ModuleVariableMatrix(cnt,:)=0;
    varsIn=info.tem.model.code.ms.(moduleNamesAll{ii}).funInput;
    varsOut=info.tem.model.code.ms.(moduleNamesAll{ii}).funOutput;
    if ~isempty(varsIn)
        [c,ia,ib]=intersect(variableNames,varsIn);
        ModuleVariableMatrix(cnt,ia)=1;
    end
    if ~isempty(varsOut)
        [c,ia,ib]=intersect(variableNames,varsOut);
        ModuleVariableMatrix(cnt,ia)=ModuleVariableMatrix(cnt,ia)+2;
    end
    moduleNames(cnt)=moduleNamesAll(ii);
    cnt=cnt+1;
end

%remove dummy modules
tmp=sum(ModuleVariableMatrix,2);
tf=tmp>0;
moduleNames=moduleNames(tf);
ModuleVariableMatrix=ModuleVariableMatrix(tf,:);
figure
imagesc(ModuleVariableMatrix)
cm=colormap(jet(4));

set(gca,'XTick',[1:nvars],'XTickLabel',variableNames,'XTickLabelRotation',45,'YTick',[1:length(moduleNames)],'YTickLabel',moduleNames)
cb=colorbar;
set(cb,'Ticks',[0,1,2,3],'TickLabels',{'Not Used','Input','Output','Modified'})

end

