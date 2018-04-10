function [FullMatrix,AllVars,FunNames,Matchmatrix]=FindAllVariablesInAllFunctions(pthModules,pthPrecsGen)

AllCode=struct;
if ispc
    Pxl=rdir([pthModules '*\*.m']);
else
    Pxl=rdir([pthModules '*/*.m']);
end

if ispc
    Mxl=rdir([pthPrecsGen '*.m']);
else
    Mxl=rdir([pthModules '*.m']);
end

for i=1:length(Mxl)
    Pxl(length(Pxl)+1)=Mxl(i);
end

for j=1:length(Pxl)
    
    [AllCode]=GatherCode(Pxl(j).name,AllCode,j);
    
end
[AllCode]=GetInputOutputFromCode(AllCode);

AllVars=[];
for i=1:length(AllCode)
    AllVars=vertcat(AllVars,AllCode(i).Input);
    AllVars=vertcat(AllVars,AllCode(i).Output);
end
AllVars=unique(AllVars);

nVars=length(AllVars);

Matchmatrix=false(length(AllVars),length(AllCode));

FunNames=cell(1,length(AllCode));

for i=1:length(AllCode)
    iI=false(nVars,1);
    iO=false(nVars,1);
    if ~isempty(AllCode(i).Input)
        [iI]=ismember(AllVars,AllCode(i).Input);
    end
    
    if ~isempty(AllCode(i).Output)
        [iO]=ismember(AllVars,AllCode(i).Output);
    end
    c=iI | iO;
    
    FunNames(i)=AllCode(i).funName;
    
    Matchmatrix(:,i)=c;
end

FullMatrix=horzcat(vertcat(['NaN'],AllVars),vertcat(FunNames,num2cell(Matchmatrix)));

% a=strcmp(AllVars(:,1),'s.GW');
% 
% v=find(Matchmatrix(a,:));
% FunNames(v)


end