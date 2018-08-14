function [f,fe,fx,s,d,info]   =     prepTEM(info)
%% prepares the experiment and model run
% INPUT:    info
% OUTPUT:   info
%           f:      forcing structure
%
% comment:
%
% steps:
%   1) prepForcing
%   4) createArrays4Model
%   5) runPrec

% %% add date helpers
% info.tem.helpers.dates.day   = createDateVector(info.tem.model.time.sDate, info.tem.model.time.eDate, 'd');
% info.tem.helpers.dates.month = createDateVector(info.tem.model.time.sDate, info.tem.model.time.eDate, 'm');

%% 1) prepare forcing data
% create function handles
fun_fields  =   fieldnames(info.tem.forcing.funName);
for jj      =   1:numel(fun_fields)
    try
    info.tem.forcing.funHandle.(fun_fields{jj})     =   str2func(info.tem.forcing.funName.(fun_fields{jj}));
    catch
        disp([pad('CRIT FUNCMISS',20,'left') ' : ' pad('prepTEM',20) ' |  no valid function name for ' fun_fields{jj} ' given in forcing.json'])
    end
end
% evaluate function handle in forcing
f           =   info.tem.forcing.funHandle.import(info);
%% get size of (1st) forcing variable for nPix and nTix
tmp                             =   fieldnames(f);
info.tem.forcing.size           =   size(f.(tmp{1}));
info.tem.helpers.sizes.nPix     =   info.tem.forcing.size(1);
info.tem.helpers.sizes.nTix     =   info.tem.forcing.size(2);

% so far based checkData4TEM.m 
if isfield(info.tem.forcing.funHandle, 'check') && ~isempty(info.tem.forcing.funHandle.check)
    [info,f] = info.tem.forcing.funHandle.check(info,f);   
end
%% setup the model structure
disp(pad('-',200,'both','-'))
disp(pad('Setup the model structure and generate the code of SINDBAD',200,'both',' '))
disp(pad('-',200,'both','-'))

% sujan: remove the code field if it exists.
if isfield(info.tem.model,'code')
    info.tem.model=rmfield(info.tem.model,'code');
end
[info]                                      =   setupCode(info);

%% create SINDBAD structures

[fe,fx,s,d,info]                =  createTEMStruct(info);


end