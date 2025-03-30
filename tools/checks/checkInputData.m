function [info,inputData] = checkInputData(info,inputData)

% checks the input data (f or obs)
% includes  1) adjusting to variable ranges
%           2) gap filling,
%           3) checking for for NaN/Inf

%% functions called within this function
% outside:
%   fillDataGaps
%   adjustVariableBounds
%   setFlag2NaN
% inside this script:
%   createMeanYearTimeSeries
%   createSpinUpYear
%   createHvec

%-------------------------------------------------------------------------
% the following ranges could move to the check_variableBounds
% conv.hPa2Pa         = 100;
% conv.kPa2Pa         = 1000;
% conv.ppm2umol       = 0.000001;
% conv.umol2mol       = 1E-6;
% conv.MJday2Wm2      = 1000000/86400;
% conv.gCday2umols    = 1000000/12/86400;
% conv.molday2umols    = 1000000/86400;
% 
range = struct;
forVar = info.tem.forcing.variableNames;
for fn = 1:numel(forVar)
    forc = forVar{fn};
    range.(forc) = info.tem.forcing.variables.(forc).bounds;
end
% range.Rain      = [ 0.0 60.0 ].*24;                 % mm/day
% range.Snow      = [ 0.0 60.0 ].*24;                 % mm/day
% range.Rg        = [ 0.0 1200.0 ]./conv.MJday2Wm2;    % MJ/m2/day
% range.PAR       = [ 0.0 600.0 ]./conv.MJday2Wm2;    % MJ/m2/day
% range.Rg_pot    = [ 0.0 1400.0 ]./conv.MJday2Wm2;   % MJ/m2/day
% range.Tair      = [ -100. 100. ];                   % deg C
% range.TairDay   = [ -100. 100. ];                   % deg C
% range.Tsoil     = [ -100. 100. ];                   % deg C
% range.TairDay   = [ -100. 100. ];                   % �C
% range.Tsoil     = [ -100. 100. ];                   % �C
% range.VPDDay    = [ 0 200. ].*10;                   % kPa
% range.FAPAR     = [0 1];
% range.LAI       = [0 12];

%
miss_val    = NaN;
flag_val    = -9999;

fns = fieldnames(inputData);
for i = 1:numel(fns)
    x    = inputData.(fns{i});
    if isfield(range,fns{i})
        varname = fns{i};
        if ~strcmpi(info.tem.forcing.variables.(varname).spaceTimeType, 'spatial')
        % replicate mean seasonal cycle (daily values) for length of input
        % time series
        repvec  = createMeanYearTimeSeries(x,inputData.Year,info);
        x       = setFlag2Nan(x,flag_val);
        % set values <> range to MSC
        x       = adjustVariableBounds(x,range.(fns{i}),miss_val,varname,repvec);
        % fill data gaps with MSC
        x       = fillDataGaps(x,NaN(size(x)),varname,flag_val,1);
        x       = x{1};
        end
        sstr    =   [pad('MSG INPUT',20) ' : ' pad('checkInputData',20) ' | ' 'Checking done for ' fns{i} 'Data'];
        disp(sstr);
    end
    inputData.(fns{i})  = x;
end


% non NaNs or Infs
vns = fieldnames(inputData);
for i = 1:numel(vns)
    tmp    = inputData.(vns{i});
    if isnan(tmp(1))||isinf(tmp(1))||tmp(1)==-9999,tmp(1)=0;end
    for j = 2:numel(tmp)
        if isnan(tmp(j))||isinf(tmp(j))||tmp(j)==-9999
            tmp(j)=tmp(j-1);
        end
    end
    inputData.(vns{i})  = tmp;
end

% adjust PET < 0
if isfield(inputData, 'PET')
    inputData.PET(inputData.PET<0)=0;
end

sstr    =   [pad('MSG INPUT',20) ' : ' pad('checkInputData',20) ' | ' 'Checking of Input Data Complete'];
disp(sstr)

% create optem QAQC/filters

end % end function


% -------------------------------------------------------------------------
%% functions called within this function

% ouside:
% fillDataGaps
% adjustVariableBounds
% setFlag2NaN

% inside this script:
% createMeanYearTimeSeries
% createSpinUpYear
% createHvec

function xout    = createMeanYearTimeSeries(x,years,info)
    % creates mean year time series of daily data
    x       = createSpinUpYear(x,years,info);
    xout    = [];
    yearvec    = createHvec(unique(years));
    for i = yearvec
        if isleapyear(i) && length(years(years==i))~=366
            xtmp=[x(1:31+28) x(31+28:end)];
        else
            xtmp=x;
        end
        xout=[xout xtmp];
    end
end

% -------------------------------------------------------------------------

function x2 = createSpinUpYear(x,years,info)
    x2      = zeros(info.tem.forcing.size(1),floor(info.tem.model.time.nStepsYear));
    den     = x2;
    yearvec    = createHvec(unique(years));
    for i = yearvec
        tmp = x(:,years == i);
        if isleapyear(i)
            tmp(:,29+31)  = [];
        end
        den                 = den + double(isnan(tmp)==0);
        tmp(isnan(tmp)==1)  = 0;
        x2                  = x2+tmp;
    end
    x2    = x2 ./ den;
end %

% -------------------------------------------------------------------------

function x = createHvec(x,mkV)
    % make an horizontal vector, or vertical if(mkV)
    if isempty(x)
        return
    end
    
    if ndims(x) ~= 2
        
        sstr    =   [pad('CRIT ERROR',20) ' : ' pad('checkInputData',20) ' | ' 'Input must have 2 dimensions! ndims(x) = ' num2str(ndims(x))];
        error(sstr)
    end
    
    if size(x, 1) == 1
        return
    elseif size(x, 2) == 1
        x    = x';
    else
        str    =   [pad('CRIT ERROR',20) ' : ' pad('checkInputData',20) ' | ' 'one of input dimensions must be 1! size(x) = ' num2str(size(x))];
        error(sstr)
    end
    
    if exist('mkV','var')
        if mkV
            x    = x';
        end
    end
end
