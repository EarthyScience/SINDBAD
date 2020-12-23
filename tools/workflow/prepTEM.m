function [f,fe,fx,s,d,info]   =     prepTEM(info)
% Prepares the data and information needed for running TEM
%
% Requires:
%   - info for model run
%   - configuration of forcing
%
% Purposes:
%   - reads the forcing
%   - check and setup code for variables and model structure
%   - create the sindbad structures and arrays within
%
% Conventions:
%   - nTix = the size of second dimension of spatio-temporal ('normal') forcing variables
%       - throws error if all normal variables do not have the same size 
%   - setupCode is always executed
%       - if forward run per year, executed at the beginning of first year
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.0 on 01.07.2018

%% handle the dates and times
if ~info.tem.model.flags.runForwardYearly
    sDateRun=info.tem.model.time.sDate;
    eDateRun=info.tem.model.time.eDate;
else
    sDateRun=[num2str(info.tem.model.time.runYear) '-1-1'];
    eDateRun=[num2str(info.tem.model.time.runYear) '-12-31'];
end
info.tem.helpers.dates.day      =  createDateVector(sDateRun, eDateRun, 'd');
info.tem.helpers.dates.month    =  createDateVector(sDateRun, eDateRun, 'm');
info.tem.helpers.dates.year     =  year(info.tem.helpers.dates.day);

%% handle and read the forcing data
%--> setup the functions to read the forcing variables
fun_fields  =   fieldnames(info.tem.forcing.funName);
for jj      =   1:numel(fun_fields)
    try
        info.tem.forcing.funHandle.(fun_fields{jj})     =   str2func(info.tem.forcing.funName.(fun_fields{jj}));
    catch
        disp([pad('CRIT FUNCMISS',20,'left') ' : ' pad('prepTEM',20) ' | no valid function name for ' fun_fields{jj} ' given in forcing.json'])
    end
end
%--> read the forcing data
[f,info]           =   info.tem.forcing.funHandle.import(info);


%% get the sizes of arrays in space and time based on forcing data
forNames                             =   info.tem.forcing.variableNames;
nPixes                               =  [];
nTixes                               =  [];
normalVars                           =  {};
%--> get the information of the 'normal' spatiotemporal variable types from
% read forcing data array and info
for fni = 1:numel(forNames)
    forName = forNames{fni};
    if strcmp(info.tem.forcing.variables.(forName).spaceTimeType,'normal')
        fSize                       =   size(f.(forName));
        nPixes(end+1)               =   fSize(1);
        nTixes(end+1)               =   fSize(2);
        normalVars{end+1}           =   forName;
    end
end
%--> check if all the normal variables have same sizes, else through an
% error
if all(nPixes == nPixes(1)) && all(nTixes == nTixes(1))
    info.tem.forcing.size           =   fSize;
    info.tem.helpers.sizes.nPix     =   fSize(1);
    info.tem.helpers.sizes.nTix     =   fSize(2);
else
    erroMsg =[pad('ERR FORC SIZE',20,'left') ' : ' pad('prepTEM',20) ' | The spatiotemporal variables (normal in spaceTimeType in forcing.json) do not have consistent array sizes. Change the forcing data sizes or spaceTimeType information of the variable in json accordingly.'];
    fprintf('%s    %s    %s\n', pad('Variable',12,'left'), pad('nPix',6,'left'), pad('nTix',6,'left'));
    for vn =1:numel(normalVars)
        fprintf('%s    %s    %s\n',pad(normalVars{vn},12,'left'),pad(num2str(nPixes(vn)),6,'left'),pad(num2str(nTixes(vn)),6,'left'));
    end
    error(erroMsg)
end

% check in the mean forcing types such as soil and other have consistent
% shape
for fni = 1:numel(forNames)
    forName = forNames{fni};
    if strcmp(info.tem.forcing.variables.(forName).spaceTimeType,'spatial')
        fSize                       =   size(f.(forName));
        if fSize(1) ~= info.tem.helpers.sizes.nPix
            f.(forName) = f.(forName)';
            disp(['transposing spatial input : ', forName])
        end
    end
end

%--> check the values in the forcing data using check function provided in forcing.json 
if isfield(info.tem.forcing.funHandle, 'check') && ~isempty(info.tem.forcing.funHandle.check)
    [info,f] = info.tem.forcing.funHandle.check(info,f);   
end

%% forcing size and dates consistency 
%--> check if the forcing data size and the dates from start to end date of the experiment match. If not, adjust the dates object
if info.tem.helpers.sizes.nTix > size(info.tem.helpers.dates.day,2)
        disp([pad('WARN FORC INCONST',20,'left') ' : ' pad('prepTEM',20) ' | Forcing variable has more days in data than the number of days between start and end date'])
        info.tem.helpers.dates.day              =   createDateVector(sDateRun, datestr(daysadd(sDateRun, info.tem.helpers.sizes.nTix-1),'yyyy-mm-dd'), 'd');
end    

%% generate and create ancillary information needed for writing output or calculating cost
%--> insert time variable in dimension to be used in producing netCDF
%output in writeOutput.m
info.tem.helpers.dimension.time.day             =   info.tem.helpers.dates.day;
info.tem.helpers.dimension.time.month           =   info.tem.helpers.dates.month;
% create space helpers
try
    info.tem.helpers.dimension.space.areaPix    =   AreaGridLatLon(info.tem.model.space.latVec, info.tem.model.space.lonVec, info.tem.model.space.reso);
    info.tem.helpers.dimension.space.areaPix    =   info.tem.helpers.areaPix(:,1);
catch
    info.tem.helpers.dimension.space.areaPix    =   ones(info.tem.helpers.sizes.nPix,1);
    disp([pad('WARN DATAMISS',20,'left') ' : ' pad('prepTEM',20) ' | Space information (latitude, longitude, resolution)  missing. areaPix set to ones'])
end

%% setup the model structure, check consistency, and so on
disp(pad('-',200,'both','-'))
disp(pad('Setup the model structure and generate the code of SINDBAD',200,'both',' '))
disp(pad('-',200,'both','-'))

%--> if the field 'code' exists, remove it, and run setupCode, except in forward run mode per year after second year onward 
if ~info.tem.model.flags.runForwardYearly || (info.tem.model.flags.runForwardYearly && info.tem.model.time.runYear == info.tem.model.time.sYear)
    if isfield(info.tem.model,'code')
        info.tem.model                          =   rmfield(info.tem.model,'code');
    end
    [info]                                      =   setupCode(info);
end

%% create SINDBAD structures
[fe,fx,s,d,info]                                =   createTEMStruct(info);

end
