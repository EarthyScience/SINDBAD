function [funh_core,funh_prcO]=WriteCode(pthCodeGen,namestr,precs,modules)

%write two functions: precomp once and core (contains precomp always)

%precsGen precs

CodePth=[pthCodeGen 'core_' namestr '.m'];
[pathstr, name, ext] = fileparts(CodePth);
fid = fopen(CodePth, 'wt');

%write the core
DoAlways=1;

str=['function [s, fx, d] = ' name '(f,fe,fx,s,d,p,info);'];
fprintf(fid, '%s\n', str);


for j=1:length(precs)
    if precs(j).DoAlways==DoAlways
        
        for i=1:length(precs(j).funCont)
            fprintf(fid, '%s\n', precs(j).funCont{i});
        end
    end
end

str='for i=1:info.forcing.size(2)';
fprintf(fid, '%s\n', str);

for j=1:length(modules)
    if modules(j).DoAlways==DoAlways
        
        for i=1:length(modules(j).funCont)
            fprintf(fid, '%s\n', modules(j).funCont{i});
        end
    end
end

%end for loop
str='end';
fprintf(fid, '%s\n', str);

%end function
fprintf(fid, '%s\n', 'end');
fclose(fid);

funh_core=str2func(name);


%write the precomp once
CodePth=[pthCodeGen 'PrecO_' namestr '.m'];
[pathstr, name, ext] = fileparts(CodePth);
fid = fopen(CodePth, 'wt');

str=['function [fe,fx,d,p]=' name '(f,fe,fx,s,d,p,info);'];
fprintf(fid, '%s\n', str);

DoAlways=0;


for j=1:length(precs)
    if precs(j).DoAlways==DoAlways
        
        for i=1:length(precs(j).funCont)
            fprintf(fid, '%s\n', precs(j).funCont{i});
        end
    end
end



fprintf(fid, '%s\n', 'end');
fclose(fid);

path(path,pthCodeGen);
funh_prcO=str2func(name);

end