function [info]    = adjustInfo(info, tree)
%% checks the (edited) info settings for dependent fields and adjusts them
% INPUT:    info
%
% OUTPUT:   info

% steps:
%   1) do approach and params agree?
%   2) are param values in bounds? -> should move as seperate function
%   3) are info.opti.params a subset of info.tem.params?
%   4) do flas.check.Numeric/Bounds and variables.to.check agree?

%% 1) approach & parameter
if ~isempty(tree)
    % loop changed field values to remove nested cells
    changedFields = {};
    for ii=1:size(tree,2)
        if size(tree{ii},2) == 1
            changedFields = [changedFields, tree(ii)];
        end
    end
    changedFields    = cell(vertcat(changedFields{:}));
    
    % check if apprName has changed
    changedAppr = strfind(changedFields,'apprName');
    idxAppr     = find(~cellfun(@isempty,changedAppr));
    
    % adjust the params in the info accordingly
    if ~isempty(idxAppr)
        % the previous params
        paramInput    = info.tem.model.variables.paramInput;
        
        for ii=1:length(idxAppr)
            apprField = changedFields{idxAppr(ii)};
            % get the module
            apprField = strsplit(apprField,'.');
            module    = char(apprField(end-1));
            % get the new approachName from the info
            appr        = info.tem.model.modules.(module).apprName;
            
            % remove previous params of changed approach
            % in tem
%             paramRem        = strfind(paramInput,module); % did not work before if it was a pasrtial match...
            paramRem        = strfind(paramInput,['p.' module '.']); % did not work before if it was a pasrtial match...
            idxRem          = find(~cellfun(@isempty,paramRem)); %the param that is removed            
            if ~isempty(idxRem)
                % remove param names under modules
                info.tem.params = rmfield(info.tem.params,module);
                % remove them in list
                paramInput(idxRem) = [];
                % in opti
                if isfield(info, 'opti')
                    paramOpti   = info.opti.paramsList;
                    paramScale      = info.opti.paramsScale;
                    % paramRemOpti    = strfind(paramOpti,module); % did not work before if it was a pasrtial match...
                    paramRemOpti    = strfind(paramOpti,['p.' module '.']);
                    idxRemOpti      = find(~cellfun(@isempty,paramRemOpti)); %the params that is removed
                    % remove param names under modules
                    info.opti.params = rmfield(info.opti.params,module);
                    % remove them in list
                    paramOpti(idxRemOpti)  = [];
                    paramScale(idxRemOpti) = [];
                    info.opti.paramsList    = paramOpti;
                    info.opti.paramsScale   = paramScale;

                end
            end
            
            % load default parameter value
            file_json   = convertToFullPaths(info,['./model/modules/' module '/' module '_' appr  '/' module '_' appr '.json']);
            
            if exist(file_json,'file')
                param_json    = readJsonFile(file_json);
                paramName     = fieldnames(param_json.params);
                % loop over the parameter of the approach & get the default value
                for pp=1:numel(paramName)
                    info.tem.params.(module).(paramName{pp}) = param_json.params.(paramName{pp}).Default;
                    paramInput = [paramInput ['p.', module, '.', paramName{pp}]];
                    
                    % get the parameter info for opti?
                    if isfield(info, 'opti')
                        info.opti.params.(module).(paramName{pp})   = param_json.params.(paramName{pp});
                        paramOpti  = vertcat(paramOpti, ['p.', module, '.', paramName{pp}]);
                        paramScale = vertcat(paramScale, 1);
                        
                        info.opti.paramsList    = paramOpti;
                        info.opti.paramsScale   = paramScale;
                    end
                end
            else
                disp([pad('WARN PARAM FILEMISS',20) ' : ' pad('adjustInfo',20) ' | no parameter config file (json) existing for adjusted module : '  module ' : approach: ' appr]);
            end
            
            % feed list of params
            info.tem.model.variables.paramInput = paramInput;
            
        end
    end
    
end

%% 2) bounds of parameter
checkParamBounds(info)
   

%% 3) opti.params & tem.params

if isfield(info, 'opti')
    if info.tem.model.flags.runOpti
        
        idxError = find(~ismember(info.opti.params.names, info.tem.model.variables.paramInput));
        if idxError ~= 0
            for ii=1:length(idxError)
                disp([pad('WARN PARAM MISS',20) ' : ' pad('adjustInfo',20) ' | Adjusted optimization parameter: ' info.opti.paramsList{idxError(ii)} ' does not exist for selected model structure and is excluded from optimization!']);
                tmp     = strsplit(info.opti.paramsList{idxError(ii)},'.');
                info.opti.params.(tmp{2})    = rmfield(info.opti.params.(tmp{2}), tmp{3});
                info.opti.paramsList(idxError(ii)) = [];
                info.opti.paramsScale(idxError(ii)) = [];
            end
        end
    end
end


%% 4) checks numeric and bounds
% if flags are true, use variables.to.check from config, or 'all'
% numeric
if info.tem.model.flags.checks.numeric == true
    if isfield(info.tem.model.variables.to, 'check')==0
        info.tem.model.variables.to.check = {'all'};
    elseif isempty(info.tem.model.variables.to.check)
        info.tem.model.variables.to.check = {'all'};
    end
end

% bounds
if info.tem.model.flags.checks.bounds == true
    if isfield(info.tem.model.variables.to, 'check')==0
        info.tem.model.variables.to.check = {'all'};
    elseif isempty(info.tem.model.variables.to.check)
        info.tem.model.variables.to.check = {'all'};
    end
end

end