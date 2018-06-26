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
%   2) prepSpinup
%   3) prepParams
%   4) createArrays4Model (helpers)
%   5) runPrec

%% 1) prepare forcing data
% create function handles
fun_fields  =   fieldnames(info.tem.forcing.funName);
for jj      =   1:numel(fun_fields)
    info.tem.forcing.funHandle.(fun_fields{jj})     =   str2func(info.tem.forcing.funName.(fun_fields{jj}));
end

% evaluate function handle in forcing
f           =   info.tem.forcing.funHandle.import(info);

%--> ncarval/sujan try making a larger forcing for a test of speed
% fnew      =   struct;
% for v     =   fieldnames(f)'
%     if ~strcmp(v{:},'Year')
%     fnew.(v{:})       =   repmat(f.(v{:}),2,1);
%     else
%         fnew.(v{:})   =   f.(v{:});
%     end
% end
% f                     =   fnew;
%<--
%%
% get size of (1st) forcing variable for nPix and nTix
tmp                             =   fieldnames(f);
info.tem.forcing.size           =   size(f.(tmp{1}));
info.tem.helpers.sizes.nPix     =   info.tem.forcing.size(1);
info.tem.helpers.sizes.nTix     =   info.tem.forcing.size(2);

% 2) check forcing
% so far based checkData4TEM.m 
if isfield(info.tem.forcing.funHandle, 'check') && ~isempty(info.tem.forcing.funHandle.check)
    [info,f] = info.tem.forcing.funHandle.check(info,f);   
end
%%
% preparing params
% p                 =   info.tem.params;

[fe,fx,s,d,info]                =  createTEMStruct(info);

%% note: this was in the setupTEM
% create the output path if it not yet exists
if ~exist(info.experiment.outputDirPath, 'dir'), mkdir(info.experiment.outputDirPath);
elseif exist(info.experiment.outputDirPath, 'dir', ;end


end