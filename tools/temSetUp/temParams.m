function params = temParams(info)
% #########################################################################
% FUNCTION	: 
% 
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: Nuno
% 
% INPUT     :
% 
% OUTPUT    :
% 
% #########################################################################

% get the standard parameter values for TEM
% these are not model structures
notModules	= {'Inputs','paths'};
% names of the fields in model structure array
msNames     = info.modules;
% initialize the output
params      = struct;
% for all modules get the standard parameters from the xlsx (or xls) files
for i = 1:numel(msNames)
    % if not a module, continue
    if ~isempty(strmatch(msNames{i},notModules,'exact'))
        continue
    end
    % get path to the xls or xlsx file, and check that it exists
    corexlsxfile	= [info.paths.core 'Modules' filesep msNames{i} filesep info.approaches{i} '.xlsx'];
    if ~exist(corexlsxfile,'file')
        corexlsxfile	= [info.paths.core 'Modules' filesep msNames{i} filesep info.approaches{i} '.xls'];
        if ~exist(corexlsxfile,'file')
            disp(['temParams : no file for ' corexlsxfile])
            continue
        end
    end
    % get the parameters from the file
    [num, txt, raw] = xlsread(corexlsxfile, 'Params');
    % check that the raw is not only the titles
    if size(raw,1)==1
        continue
    end
    % feed them into the structure array params
    col1	= strmatch('VariableName',raw(1,:),'exact');
    col2    = strmatch('Default',raw(1,:),'exact');
    % check if the parameter structure for this module already exists
    if isempty(strmatch(msNames{i},fieldnames(params)))
        % if not, create it as a structure
        params.(msNames{i})	= struct;
    end
    % read the xlsx file
    for j = 2:size(raw,1)
        % the parameter value
        p	= raw{j,col2};
        % parameter name
        pName	= raw{j,col1};
        % if isnan, empty, or whatever, jump
        if isempty(pName), continue, end
        if ~ischar(pName)
            if sum(isnan(pName)) > 0
                continue
            end
        end
        % if the parameters are per PFT we have to spread them through the
        % yy dimension of the PFT...
        if ~isempty(strfind(raw{j,col1},'.PFT('))
            % get the name of the parameter
            ndx     = strfind(pName,'.PFT(');
            pName	= pName(1:ndx-1);
            % which PFT
            wPFT	= str2double(raw{j,col1}(ndx+5:end-1));
            % check if this parameter field already exists
            if isempty(strmatch(pName,fieldnames(params.(msNames{i}))))
                % if not, create it as empty NaNs
                params.(msNames{i}).(pName) = NaN(info.forcing.size(1),1);
            end
            % fill the PFT records
            eval(['params.(msNames{i}).' pName '(params.VEG.PFT==wPFT) = p;']);
        else
            % otherwise, the dimensions of the parameter have to be the
            % same as the yy dimensions (key for spatial optimizations when
            % the parameters are upscale per PFT)
            eval(['params.(msNames{i}).' pName ' = ones(info.forcing.size(1),1) .* p;']);
        end
    end
end

end % function
