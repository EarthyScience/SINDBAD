function [fe,fx,s,d]=PreAllocateModelStructs(precs,modules,ntime,nspace)
%Preallocate fe,fx,s,d
allF={''};
for i=1:length(precs)
    allF=vertcat(allF,precs(i).Input);
    allF=vertcat(allF,precs(i).Output);
end
for i=1:length(modules)
    allF=vertcat(allF,modules(i).Input);
    allF=vertcat(allF,modules(i).Output);
end
allF=unique(allF);

%get rid of the params
TF = strncmp('p.',allF,2);
allF=allF(TF==0);

dummy=NaN(nspace,ntime);

fe=struct;
fx=struct;
d=struct;
s=struct;

%k = strfind(allF, 'fe.');
%idx=find(cellfun(@isempty,k)==0);
%for i=1:length(idx)
for i=1:length(allF)
    %eval(['fe.' char(allF(idx(i))) '=dummy;']);
    eval([char(allF(i)) '=dummy;']);
end
end