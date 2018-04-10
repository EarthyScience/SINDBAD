function info                    = temFullSetup(varargin)
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

% info = temFullSetup
% info = temFullSetup('info','PFT',1,...)
% info = temFullSetup('info','PFT',1,...,'ms','RunoffSat','none',...)

% initialize inputs for the temInfo, tempStruct and temParams
varsOutInfo                      = {};
varsOutMs                        = {};
for i                            = 1:numel(varargin)
    if i == 1 && ...
            ~(strcmpi(varargin{i},'info') || strcmpi(varargin{i},'ms'))
        error('ERR : temFullSetup : first argument must select the type of structure information: info, ms or optem')
    elseif strcmpi(varargin{i},'info') || strcmpi(varargin{i},'ms') || strcmpi(varargin{i},'optem')
        pS	= lower(varargin{i});
        continue
    end
    switch pS
        case 'info'
            varsOutInfo{numel(varsOutInfo)+1}	= varargin{i};
        case 'ms'
            varsOutMs{numel(varsOutMs)+1}    = varargin{i};
        otherwise
            error(['ERR : temFullSetup : Not a known pS : ' pS])
    end
end

% info
if ~isempty(varsOutInfo);   info	= temInfo(varsOutInfo{:});
else                        info = temInfo;
end

% model structure
if ~isempty(varsOutMs);     [appr, modu]	= temApproaches(info,varsOutMs{:});
else                        [appr, modu]	= temApproaches(info);
end
% merge the infos...
info.approaches                  = appr;
info.modules                     = modu;
%info.code       = psCode;
% get the standard parameters of SINDBAD
info	= temParams(info);
% helpers
info                             = temHelpers(info);
% what to save and not
info                             = temStatesToSave(info);
% make the model structure
if ~info.flags.genCode
    disp('MSG : temFullSetup : code is always generated!')
end
%info    = rmfield(info,'code');
% optem
if info.flags.opti
    info	= temOptimization(info);
end
info	= SetupInfoModelStructure(info);
end % function

