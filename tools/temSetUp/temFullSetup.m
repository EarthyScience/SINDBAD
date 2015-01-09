function info = temFullSetup(varargin)
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


if nargin == 0
    % if no arguments, just get the standard values
    [appr, modu]    = temApproaches;    % get a standard ms (model structure) for SINDBAD
    info            = temInfo;          % get a standard info (information structure) for SINDBAD
    info.approaches = appr;       % merge them
    info.modules    = modu;       % merge them
    pars            = temParams(info);  % get the standard parameters of SINDBAD
    info.params     = pars;             % set it into info
    return
else
    % otherwise get the different inputs
    % initialize inputs for the temInfo, tempStruct and temParams
    varsOutInfo = {};
    varsOutms   = {};
    for i = 1:numel(varargin)
        if i == 1 && ...
                ~(strcmpi(varargin{i},'info') || strcmpi(varargin{i},'ms'))
            error('first argument must select the type of structure information: info, ms or pars')
        elseif strcmpi(varargin{i},'info') || strcmpi(varargin{i},'ms')
            pS	= lower(varargin{i});
            continue
        end
        switch pS
            case 'info' % inputs for the temInfo
                varsOutInfo{numel(varsOutInfo) + 1}	= varargin{i};
            case 'ms'   % inputs for the tempStruct
                varsOutms{numel(varsOutms) + 1}     = varargin{i};
            otherwise
                error(['Not a known pS : ' pS])
        end
    end
end

% model structure
if ~isempty(varsOutms);     [appr, modu, psCode]	= temApproaches(varsOutms{:});
else                        [appr, modu, psCode]	= temApproaches;
end
% info
if ~isempty(varsOutInfo);   info	= temInfo(varsOutInfo{:});
else                        info    = temInfo;
end
info.approaches = appr;       % merge them
info.modules    = modu;       % merge them
pars            = temParams(info);  % get the standard parameters of SINDBAD
info.params 	= pars;             % set it into info

% make the model structure
if info.flags.genCode
    info        = SetupInfoModelStructure(info);
else
    info.code	= psCode;
end

end % function