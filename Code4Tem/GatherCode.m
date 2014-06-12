function [precs]=GatherCode(xpth,precs,cnt);
        
        [pathstr, FunName, ext] = fileparts(xpth);
        %set path
        path(path,pathstr);
        %generate handle
        precs(cnt).fun=str2func(FunName);
        %get contents of function
        [funCont]=GetMfunctionContents([pathstr '/' FunName '.m']);
        precs(cnt).funCont=funCont;
        precs(cnt).funPath=cellstr(pathstr);
        precs(cnt).funName=cellstr(FunName);
end