function [info]=WriteCode(info)

pthCodeGen=info.paths.genCode;
namestr=info.experimentName;

%write two functions: precomp once and core (contains precomp always)

%precsGen precs

if~exist(pthCodeGen,'dir'),mkdir(pthCodeGen);end

CodePth=[pthCodeGen 'core_' namestr '.m'];
[pathstr, name, ext] = fileparts(CodePth);

if exist(CodePth,'file')
    delete(CodePth);
end

fid = fopen(CodePth, 'wt');

%write the core
doAlways=1;

str=['function [fx,s,d] = ' name '(f,fe,fx,s,d,p,info);'];
fprintf(fid, '%s\n', str);

precs=info.code.preComp;
for j=1:length(precs)
    if precs(j).doAlways==doAlways
        
        for i=1:length(precs(j).funCont)
            fprintf(fid, '%s\n', precs(j).funCont{i});
        end
    end
end

str='for i=1:info.forcing.size(2)';
fprintf(fid, '%s\n', str);

modules_fn=fieldnames(info.code.ms);
for j=1:length(modules_fn)
    eval(['cmodule=info.code.ms.' char(modules_fn(j)) ';']);
    %if modules(j).doAlways==doAlways
    if cmodule.doAlways==doAlways
        
        if strcmp(cmodule.funName,'PutStates_simple')
            %%%%
            cvars	= info.variables.rememberState;
            for ii = 1:length(cvars)
                cvar	= char(cvars(ii));
                tmp     = splitZstr(cvar,'.');
                if strncmp(cvar,'s.',2) || strncmp(cvar,'d.Temp.',7)
                    sstr=['d.Temp.p' char(tmp(end)) ' = ' cvar ';'];
                    %eval(['d.Temp.p' char(tmp(end)) ' = ' cvar ';'])
                else
                    %eval(['d.Temp.p' char(tmp(end)) ' = ' cvar '(:,i);'])
                    sstr=['d.Temp.p' char(tmp(end)) ' = ' cvar '(:,i);'];
                end
                fprintf(fid, '%s\n', sstr);
            end
            
            cvars = info.variables.saveState;
            for ii = 1:length(cvars)
                cvar    = char(cvars(ii));
                tmp     = splitZstr(cvar,'.');
                tmpVN   = char(tmp(end));
                
                if strcmp(tmpVN,'value');
                    tmpVN   = [char(tmp(end-1)) '.' char(tmp(end))];
                end
                
                if strncmp(cvar,'s.',2)
                    %eval(['d.statesOut.' tmpVN '(:,i) = ' cvar ';'])
                    sstr=['d.statesOut.' tmpVN '(:,i) = ' cvar ';'];
                    fprintf(fid, '%s\n', sstr);
                end
                
                
            end
            %%%%%
        else
            
            %for i=1:length(modules(j).funCont)
            for i=1:length(cmodule.funCont)
                %fprintf(fid, '%s\n', modules(j).funCont{i});
                fprintf(fid, '%s\n', cmodule.funCont{i});
            end
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%write the precomp once
CodePth=[pthCodeGen 'PrecO_' namestr '.m'];
[pathstr, name, ext] = fileparts(CodePth);

if exist(CodePth,'file')
    delete(CodePth);
end


fid = fopen(CodePth, 'wt');

str=['function [fe,fx,d,p]=' name '(f,fe,fx,s,d,p,info);'];
fprintf(fid, '%s\n', str);

doAlways=0;


for j=1:length(precs)
    if precs(j).doAlways==doAlways
        
        for i=1:length(precs(j).funCont)
            fprintf(fid, '%s\n', precs(j).funCont{i});
        end
    end
end


fprintf(fid, '%s\n', 'end');
fclose(fid);

path(path,pthCodeGen);
funh_prcO=str2func(name);

info.code.msi.core=funh_core;
info.code.msi.preComp=funh_prcO;

%%%%%%%%%%%%%%%%%%%%%for spinup
tmodules={'AutoResp','CCycle'};

CodePth=[pthCodeGen 'core_4SpinupCCycle_' namestr '.m'];
[pathstr, name, ext] = fileparts(CodePth);

if exist(CodePth,'file')
    delete(CodePth);
end

fid = fopen(CodePth, 'wt');

%write the core
doAlways=1;

str=['function [fx,s,d] = ' name '(f,fe,fx,s,d,p,info);'];
fprintf(fid, '%s\n', str);

precs=info.code.preComp;
for j=1:length(precs)
    cn=precs(j).funName;
    tmp=strsplit(char(cn),'_');
    cn=tmp(2);
    tf=strcmp(cn,tmodules);
    if precs(j).doAlways==doAlways && max(tf)==1
        
        for i=1:length(precs(j).funCont)
            fprintf(fid, '%s\n', precs(j).funCont{i});
        end
    end
end

str='for i=1:info.forcing.size(2)';
fprintf(fid, '%s\n', str);

%modules_fn=fieldnames(info.code.ms);
modules_fn=tmodules;
for j=1:length(modules_fn)
    eval(['cmodule=info.code.ms.' char(modules_fn(j)) ';']);
    %if modules(j).doAlways==doAlways
    if cmodule.doAlways==doAlways
        
        if strcmp(cmodule.funName,'PutStates_simple')
            %%%%
            cvars	= info.variables.rememberState;
            for ii = 1:length(cvars)
                cvar	= char(cvars(ii));
                tmp     = splitZstr(cvar,'.');
                if strncmp(cvar,'s.',2) || strncmp(cvar,'d.Temp.',7)
                    sstr=['d.Temp.p' char(tmp(end)) ' = ' cvar ';'];
                    %eval(['d.Temp.p' char(tmp(end)) ' = ' cvar ';'])
                else
                    %eval(['d.Temp.p' char(tmp(end)) ' = ' cvar '(:,i);'])
                    sstr=['d.Temp.p' char(tmp(end)) ' = ' cvar '(:,i);'];
                end
                fprintf(fid, '%s\n', sstr);
            end
            
            cvars = info.variables.saveState;
            for ii = 1:length(cvars)
                cvar    = char(cvars(ii));
                tmp     = splitZstr(cvar,'.');
                tmpVN   = char(tmp(end));
                
                if strcmp(tmpVN,'value');
                    tmpVN   = [char(tmp(end-1)) '.' char(tmp(end))];
                end
                
                if strncmp(cvar,'s.',2)
                    %eval(['d.statesOut.' tmpVN '(:,i) = ' cvar ';'])
                    sstr=['d.statesOut.' tmpVN '(:,i) = ' cvar ';'];
                    fprintf(fid, '%s\n', sstr);
                end
                
                
            end
            %%%%%
        else
            
            %for i=1:length(modules(j).funCont)
            for i=1:length(cmodule.funCont)
                %fprintf(fid, '%s\n', modules(j).funCont{i});
                fprintf(fid, '%s\n', cmodule.funCont{i});
            end
        end
    end
end

%end for loop
str='end';
fprintf(fid, '%s\n', str);

%end function
fprintf(fid, '%s\n', 'end');
fclose(fid);

funh_coreSpinUp=str2func(name);


%write the precomp once
CodePth=[pthCodeGen 'PrecO_4SpinupCCycle_' namestr '.m'];
[pathstr, name, ext] = fileparts(CodePth);

if exist(CodePth,'file')
    delete(CodePth);
end


fid = fopen(CodePth, 'wt');

str=['function [fe,fx,d,p]=' name '(f,fe,fx,s,d,p,info);'];
fprintf(fid, '%s\n', str);

doAlways=0;


for j=1:length(precs)
    
    cn=precs(j).funName;
    tmp=strsplit(char(cn),'_');
    cn=tmp(2);
    tf=strcmp(cn,tmodules);
    if precs(j).doAlways==doAlways && max(tf)==1
        for i=1:length(precs(j).funCont)
            fprintf(fid, '%s\n', precs(j).funCont{i});
        end
    end
end


fprintf(fid, '%s\n', 'end');
fclose(fid);

path(path,pthCodeGen);
funh_prcOSpinUp=str2func(name);

info.code.msi.coreSpinUp=funh_prcOSpinUp;
info.code.msi.preCompSpinUp=funh_prcOSpinUp;

end