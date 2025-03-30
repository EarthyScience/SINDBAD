function fSpin    =    prepSpinupForcing(f,info)
% Prepare the forcing for the spinup run of SINDBAD TEM
%
% Requires:
%   - The info with rules on what to do with spinup forcing
%   (info.tem.spinup)
%   - f when the forcing dataset is to be created from the original forcing
%
% Purposes:
%   - Creates the forcing for spinup with same fields as the original forcing
%
% Conventions:
%   - may create a forcing of variable sizes
%   - needs a careful input of nLoops in sequence spinup configuration (spinup.json)
%       - For example, a MSC can be looped much more times than shuffled or
%       the full original forcing
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Nuno Carvalhais (ncarval)
%
% References:
%   -
% Versions:
%   - 1.2 om 29.11.2019: skoirala: do not recycle MSC when variables do not
%   have a time dimension
%   - 1.1 on 10.07.2018: includes handling of spinup forcing from other
%   functions
%   - 1.0 on 10.04.2018

%%
fSpin    = f;

if info.tem.spinup.flags.readForcing
    if ~isempty(info.tem.spinup.rules.fun2readForcing)
        fSpinHandle = str2func(info.tem.spinup.rules.fun2readForcing);
        [fSpin, info] = feval(fSpinHandle,info);
    else
        disp([pad('SPINUP FORC',20) ' : ' pad('prepSpinupForcing',20) ' | Forcing for spinup is set to read from file, but the function to do it (fun2readForcing) is empty. Using the original forcing'] )
    end
end


if info.tem.spinup.flags.recycleMSC
    % do a mean season cycle
    fns     = fieldnames(f);
    for jj  = 1:numel(fns)
        if strcmpi(fns{jj},'Year'),continue,end
        if strcmp(info.tem.forcing.variables.(fns{jj}).spaceTimeType,'spatial')
            %--> skoirala: if part of the forcing data does not have a
            %temporal dimension, just copy it to the spinup forcing
            fSpin.(fns{jj})    =    f.(fns{jj});
        else  
            tmp             =    f.(fns{jj});
            tmp             =    getForcingMSC(tmp,f.Year,info);
            fSpin.(fns{jj})    =    tmp;
            YearSize        =   size(tmp);
        end
    end
    % dummy year for the spinup
    fSpin.Year          = ones(YearSize,info.tem.model.rules.arrayPrecision) .* 1901;
    
end
if ~info.tem.spinup.flags.readForcing
    if info.tem.spinup.flags.recycleMSC
        disp([pad('SPINUP FORC',20) ' : ' pad('prepSpinupForcing',20) ' | using recycled MSC of original forcing for model spinup'])
    else
        disp([pad('SPINUP FORC',20) ' : ' pad('prepSpinupForcing',20) ' | using one forward run of original forcing for model spinup'])
    end
elseif ~isempty(info.tem.spinup.rules.fun2readForcing)
    if ~info.tem.spinup.flags.recycleMSC
        disp([pad('SPINUP FORC',20) ' : ' pad('prepSpinupForcing',20) ' | using one forward run of new spinup forcing from | ' info.tem.spinup.rules.fun2readForcing ' | for model spinup'])
    else
        disp([pad('SPINUP FORC',20) ' : ' pad('prepSpinupForcing',20) ' | using recycled MSC of new spinup forcing from | ' info.tem.spinup.rules.fun2readForcing ' | for model spinup'])
    end 
end

end
