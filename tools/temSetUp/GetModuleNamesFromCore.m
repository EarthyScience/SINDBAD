function [ModuleNames]=GetModuleNamesFromCore(pthCore)

[C]=GetMfunctionContents(pthCore);

%look for 'ms.' and '.fun'

st=strfind(C,'ms.');
en=strfind(C,'.fun');

ModuleNames={''};
cnt=1;
for i=1:length(C)
    if ~isempty(st{i}) && ~isempty(en{i})

        cs=char(C(i));
        ModuleNames(cnt,1)=cellstr(cs(st{i}+3:en{i}-1));
        cnt=cnt+1;
    end
end


end