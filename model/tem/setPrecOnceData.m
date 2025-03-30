function [precOnceData,f,fe,fx,s,d,p] = setPrecOnceData(precOnceData,f,fe,fx,s,d,p,info,runMode)
% sets field of precOnceData from SINDBAD structures or vice-versa
%
% Requires:
%    - precOnceData or/and SINDBAD structures (f,fe,fx,s,d,p)
%
% Purposes:
%   - if PrecOnceData is empty, fills its fields with SINDBAD structures
%   - if PrecOnceData is full, replaces the SINDBAD structure with fields
%   of PrecOnceData
%   
%
% Conventions:
%  - If runOpti == 1 (in optimization mode), p from optimizer is taken
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.0 on 01.07.2018

%%
strList = {'f','fe','fx','s','d','p'};

if isempty(precOnceData)
    [f,fe,fx,s,d,p] = runCoreTEM(f,fe,fx,s,d,p,info,true,false,false);
    strInpt         = repmat([strList; repmat({NaN},1,numel(strList))],1,1);
    precOnceData    = struct(strInpt{:});
    for strLi = 1:numel(strList)
        strName = strList{strLi};
        eval(['precOnceData.(strName)    = ' strName ';']);
    end
    disp([pad('SET PRECDATA',20)  ' : ' pad('setPrecOnceData',20) ' | ' pad(runMode,20) ' | EMPTY PrecOnceData fields replaced by SINDBAD structures'])
else
    for strLi = 1:numel(strList)
        strName = strList{strLi};
        
        if strcmp(strName,'p') && info.tem.model.flags.runOpti
            optiParams = info.opti.params.names;
            for op = 1:numel(optiParams)
                optiParamName = optiParams{op};
%                 evalStr = ['precOnceData.' optiParamName ' = ' optiParamName ';']
                %             eval(['precOnceData.' info.opti.params.names{op} ' = ' info.opti.params.names{op} ';']);
                eval(['precOnceData.' optiParamName ' = ' optiParamName ';']);
            end
            disp([pad('SET PRECDATA',20) ' : ' pad('setPrecOnceData',20) ' | ' pad(runMode,20) ' | Optimization | Replacing  Optimized Parameters in PrecOnceData.p field'])
        else
            eval([strName ' = precOnceData.(strName);']);
        end
            
    end
end
disp([pad('SET PRECDATA',20)  ' : ' pad('setPrecOnceData',20) ' | ' pad(runMode,20) ' | SINDBAD structures replaced by NON-EMPTY PrecOnceData fields'])
end