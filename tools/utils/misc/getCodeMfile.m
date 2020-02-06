function [codeStruct]=getCodeMfile(xpth)
codeStruct = struct;
cnt=1;
[pathstr, FunName, ext] = fileparts(xpth);
%set path
path(path,pathstr);
%generate handle
codeStruct(cnt).funHandle=str2func(FunName);
%get contents of function
[funCont]=readMfunctionContents([pathstr '/' FunName '.m']);
%mfinfo = mfileread([pathstr '/' FunName '.m']);
%funCont=mfinfo.code;

[funCont]=beautifyFunCont(funCont);

codeStruct(cnt).funContent=funCont;
codeStruct(cnt).funPath=cellstr(pathstr);
codeStruct(cnt).funName=cellstr(FunName);
[codeStruct]=getInputOutputFromModelCode(codeStruct);
end
%%
function [codeStruct]=getInputOutputFromModelCode(codeStruct)


sstr={...
    '\<p\.\w[\w\d_]*\.\w[\w\d_]*',...
    '\<d\.\w[\w\d_]*\.\w[\w\d_]*',...
    '\<fe\.\w[\w\d_]*\.\w[\w\d_]*',...    '\<fe\.\w[\w\d_]*',...
    '\<f\.\w[\w\d_]*',...
    '\<fx\.\w[\w\d_]*',...
    '\<s\.\w[\w\d_]*\.\w[\w\d_]*'};

for i=1:length(codeStruct)
    Output={[]};
    Input={[]};
    cntI=1;
    cntO=1;

    [starteq] =regexp(codeStruct(i).funContent,'=');
    [startComment]=regexp(codeStruct(i).funContent,'%');

    for j=1:length(sstr)

        %         [matchstart,matchend,tokenindices,matchstring,tokenstring, tokenname,splitstring] =regexp(precs(i).funCont,sstr(j));
        [matchstart,matchend,tokenindices,matchstring,tokenstring, tokenname] =regexp(codeStruct(i).funContent,sstr(j));

        v=find(cellfun(@isempty,matchstart)==0);
        for k=1:length(v)
            cv=v(k);
            cl=length(matchstart{cv});
            cmstart=matchstart{cv};
            ceq=starteq{cv};
            ceq=ceq(1);
            cstring=matchstring{cv};
            ccomment=startComment{cv};
            if ~isempty(ccomment)
                ccomment=ccomment(1);
            else
                ccomment=Inf;
            end
            for l=1:cl
                if cmstart(l) < ceq
                    %is output
                    Output(cntO,1)=cstring(l);
                    cntO=cntO+1;
                else
                    if cmstart(l) < ccomment
                        Input(cntI,1)=cstring(l);
                        cntI=cntI+1;
                    end
                    %is input

                end
            end

        end

    end
    if ~isempty(Input{1})
        codeStruct(i).funInput=unique(Input);
    end
    if ~isempty(Output{1})
        codeStruct(i).funOutput=unique(Output);
    end

end

end
%%

function [C]=readMfunctionContents(mpth)

%fid = fopen(mpth);
%C = textscan(fid, '%s', 'delimiter', '?','CommentStyle','%'); %%check if mlint does extract the comments (2018-01-18)
%fclose(fid);
%C=C{1};

mfinfo = mfileread(mpth);
C=mfinfo.code;

%check if last line is 'end' or 'return';

if strncmp(C(end),'return',6) || strncmp(C(end),'end',3)
    C=C(2:end-1);
else
    C=C(2:end);
end

[pathstr,name,ext] = fileparts(mpth);

%find mfunctions in directory
mf=dir([pathstr '/' '*.m']);

%check if you find it in C
for ii=1:length(mf)
    %Comment: on Linux, the following line will only work for absolute paths
    [pathstr2,name,ext] = fileparts(mf(ii).name);

    tmp=regexp(C,[name '\s*(']); %added '(' to make sure its a function call and not e.g. confused with an error message

    for iii=1:length(tmp)

        if ~isempty(tmp{iii})
            %something found
            P1=C(1:iii-1);

            [P2]=readMfunctionContents([pathstr '/' mf(ii).name]);

            P3=C(iii+1:end);
            C=vertcat(P1,P2,P3);
        end
    end
end
end
%%
function [funCont]=beautifyFunCont(funCont)

%
funCont=regexprep(funCont,'=',' = ');

tf=endsWith(funCont,';');
rtf=tf==0;
tmp=funCont(rtf);
for i=1:length(tmp)
    tmp{i}=[tmp{i} ';'];
end
funCont(rtf)=tmp;
end
%%
function mfinfo = mfileread(file)
%MFINFO = MFILEREAD(filename);
%
% MFILEREAD reads an m-file and returns its code and comment part
%
% More specifically, it returns a struct MFINFO with the fields
% FILENAME  .. name of m-file
% LINECOUNT .. the number of non-empty lines in the m-file
% TEXT .. compact representation of whole text line by line, excluding empty lines
% CODE .. compact representation of code only in a cell
% COMMENT .. compact representation of comments only in a  cell

% Comments are identified as the part of text after the first %-character which is not part of string

%
% (c) 19-12-2010, Mathias Benedek

% changed by NC
% same rules of comments for the "..."

code        = '';
comm        = '';
mtext       = '';
linecount   = 0;

% read the file line by line
k       = 0;
tlinef  = {};
fid     = fopen(file);
while 1
    k       = k + 1;
    tline   = fgets(fid);
    if ~ischar(tline),   break,   end
    tlinef{k}   = tline;
    mtext       = [mtext, tline, char(13)];
    if ~isempty(tline)
        linecount = linecount+1;
    end
end
fclose(fid);

%% remove multiple lines...
k = 1;
while k < numel(tlinef)
    tline   = rmComm(strtrim(tlinef{k}),0,true);
    newk    = k + 1;
    if isempty(tline)
        tlinef{k}    = '';
        k           = newk;
        continue
    end
    % Find first "..." that is not part of string
    pcts_idx = strfind(tline,'...');
    if pcts_idx
        % identify comments
        comm_idx = length(tline);
        for ii = pcts_idx
            c_idx = strfind(tline(1:ii),'''');
            if mod(length(c_idx),2) == 0  % even number of ' -characters
                comm_idx = ii;
                break;
            end
        end
        % cat the next line in case ... is present
        if comm_idx > 1 && comm_idx<length(tline)
            tlinef{k}    = [strtrim(tline(1:comm_idx-1)), tlinef{min([k+1 numel(tlinef)])}, char(13)];
            if numel(tlinef)>k
                tlinef(k+1) = [];
                newk        = k;
            end
        end
    end
    k   = newk;
end
mfinfo.tlinef = tlinef;

%% comment explicitly the block comments
str2f = '%{';
commNow = false;
commNext = false;
for i = 1:numel(tlinef)
    tline = tlinef{i};
    if ~ischar(tline),   break,   end
    tline = strtrim(tline);
    pcts_idx = strfind(tline,str2f);
    if isequal(pcts_idx,1) && strcmp(str2f,'%{')
        commNow = true;
        commNext = true;
        str2f = '%}';
    elseif isequal(pcts_idx,1) && strcmp(str2f,'%}')
        commNow = true;
        commNext = false;
        str2f = '%{';
    end
    if commNow
        tlinef{i}   = ['% ' tlinef{i}];
    end
    if ~commNext
        commNow     = false;
    end
end

%% remove line comments
code    = cell(size(tlinef));
codek   = 1;
l2k     = [];
for i = 1:numel(tlinef)
    tline = tlinef{i};
    if ~ischar(tline),   break,   end
    [tline,codek]    = rmComm(strtrim(tlinef{i}),codek,false);
    if ~isempty(tline)
        code{codek}     = tline;
    end
end
code = code(~cellfun('isempty',code));
% outputs
mfinfo.filename     = file;
mfinfo.linecount    = linecount;
mfinfo.text         = strtrim(mtext);
mfinfo.code         = strtrim(code);
end
%%
function [outLine,codek] = rmComm(tline,codek,isMultiLine)
outLine = '';
% Find first percent sign that is not part of string
pcts_idx = strfind(tline,'%');
if sum(strcmp(strtrim(tline),{'%{','%}'})) > 0 && isMultiLine
    outLine = tline;
    pcts_idx = false;
end
if pcts_idx
    comm_idx = length(tline);
    for ii = pcts_idx
        c_idx = strfind(tline(1:ii),'''');
        if mod(length(c_idx),2) == 0  % even number of ' -characters
            comm_idx = ii;
            break;
        end
    end
    % extract the code
    if comm_idx > 1 && comm_idx < length(tline)
        outLine = strtrim(tline(1:comm_idx-1));
        codek    = codek + 1;
    end
    if comm_idx > 1 && comm_idx == length(tline)
        outLine = strtrim(tline(1:comm_idx));
        codek    = codek + 1;
    end
else
    outLine = strtrim(tline);
    codek    = codek + 1;
end
end


