function [f,fe,fx,s,d,info]   =     prepTEM(info)
%% prepares the experiment and model run
% INPUT:    info
% OUTPUT:   info
%           f:      forcing structure
%
% comment:
%
% steps:
%   1) imports the forcing
% 	2) sets up the model code
%   3) creates sindbad's structures
%% 1) prepare forcing data
% create function handles
if ~info.tem.model.flags.runForwardYearly
    sDateRun=info.tem.model.time.sDate;
    eDateRun=info.tem.model.time.eDate;
else
    sDateRun=[num2str(info.tem.model.time.runYear) '-1-1'];
    eDateRun=[num2str(info.tem.model.time.runYear) '-12-31'];
end
info.tem.helpers.dates.day      =  createDateVector(sDateRun, eDateRun, 'd');
info.tem.helpers.dates.month    =  createDateVector(sDateRun, eDateRun, 'm');

fun_fields  =   fieldnames(info.tem.forcing.funName);
for jj      =   1:numel(fun_fields)
    try
    	info.tem.forcing.funHandle.(fun_fields{jj})     =   str2func(info.tem.forcing.funName.(fun_fields{jj}));
    catch
        disp([pad('CRIT FUNCMISS',20,'left') ' : ' pad('prepTEM',20) ' | no valid function name for ' fun_fields{jj} ' given in forcing.json'])
    end
end

% evaluate function handle in forcing
[f,info]           =   info.tem.forcing.funHandle.import(info);

%% get size of (1st) forcing variable for nPix and nTix
tmp                             =   fieldnames(f);
info.tem.forcing.size           =   size(f.(tmp{1}));
info.tem.helpers.sizes.nPix     =   info.tem.forcing.size(1);
info.tem.helpers.sizes.nTix     =   info.tem.forcing.size(2);

if info.tem.helpers.sizes.nTix > size(info.tem.helpers.dates.day,2)
        disp([pad('WARN FORC INCONST',20,'left') ' : ' pad('prepTEM',20) ' | Forcing variable has more days in data than the number of days between start and end date'])
        info.tem.helpers.dates.day      =  createDateVector(sDateRun, datestr(daysadd(sDateRun, info.tem.helpers.sizes.nTix-1),'yyyy-mm-dd'), 'd');
end    

%--> insert time variable in dimension to be used in producing netCDF
%output in writeOutput.m
info.tem.helpers.dimension.time.day       = info.tem.helpers.dates.day;
info.tem.helpers.dimension.time.month     = info.tem.helpers.dates.month;
% create space helpers
try
    info.tem.helpers.dimension.space.areaPix    =   AreaGridLatLon(info.tem.model.space.latVec, info.tem.model.space.lonVec, info.tem.model.space.reso);
    info.tem.helpers.dimension.space.areaPix    =   info.tem.helpers.areaPix(:,1);
catch
    info.tem.helpers.dimension.space.areaPix    =   ones(info.tem.helpers.sizes.nPix,1);
    disp([pad('WARN DATAMISS',20,'left') ' : ' pad('prepTEM',20) ' | Space information (latitude, longitude, resolution)  missing. areaPix set to ones'])
end

% so far based checkData4TEM.m 
if isfield(info.tem.forcing.funHandle, 'check') && ~isempty(info.tem.forcing.funHandle.check)
    [info,f] = info.tem.forcing.funHandle.check(info,f);   
end

%% setup the model structure
disp(pad('-',200,'both','-'))
disp(pad('Setup the model structure and generate the code of SINDBAD',200,'both',' '))
disp(pad('-',200,'both','-'))

% sujan check if the model is run in forward mode per year
if ~info.tem.model.flags.runForwardYearly || (info.tem.model.flags.runForwardYearly && info.tem.model.time.runYear == info.tem.model.time.sYear)
% sujan: remove the code field if it exists.
if isfield(info.tem.model,'code')
    info.tem.model=rmfield(info.tem.model,'code');
end
[info]                          =   setupCode(info);
end

%% create SINDBAD structures
[fe,fx,s,d,info]                =  createTEMStruct(info);


end
