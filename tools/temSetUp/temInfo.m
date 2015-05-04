function info = temInfo(varargin)
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

%%

%% number of arguments must be even
if rem(nargin,2)~=0
    error(['number of arguments must be even: nargin = ' num2str(nargin)])
end
%% set the defaults
% experiment name
ctim                = num2str(datevec(now),'%1.0f_');
info.experimentName	= ctim(1:end-1);
% forcing
info.forcing.importFun  = '';
info.forcing.size       = [Inf Inf];
% optimization stuff
info.opti.parNames      = {};
% get the path to the core and to the tem - the function temInfo as to be
% in the same folder as the tem itself
tmp             = mfilename('fullpath');
ndx             = strfind(tmp,'temInfo');
info.paths.tem	= strrep(tmp(1:ndx(end)-1),['tools' filesep 'temSetUp'],['model' filesep 'tem']);
info.paths.core = strrep(tmp(1:ndx(end)-1),['tools' filesep 'temSetUp'],['model' filesep 'core']);

% data and model structure checks
%info.checks.numeric     = 1; %should be a cellstr like 'all', or better {fe,fx,s,d'}
info.checks.numeric     = {'fe','fx','s','d'}; %should be a cellstr like 'all', or better {fe,fx,s,d'}
%info.checks.bounds      = 1; %should be a cellstr like 'all', or better {fe,fx,s,d'}
info.checks.bounds      = {'fe','fx','s','d'}; % requires 'info.variables.bounds' see CheckBounds.m
%info.checks.ms          = 1; %not needed? will always be done during code interpretation
%info.flags.CheckWBalance= 1; %

info.checks.WBalance= 1; % need to make sure that all necessary wPools are given in info.variables.saveState - needs to checked in temToSave!!!
info.checks.CBalance= 1;
%info.flags.WBalanceOK   = 1;
%info.flags.CBalanceOK   = 1;
%info.checks.WBVioFrac   = 0;
%info.checks.CBVioFrac   = 0;
%info.flags.RanOK        = 1;

% flags for "how to run the model"
info.flags.opti         = 1;
info.flags.forwardRun	= 0;
info.flags.checkForcing	= 1;
info.flags.doSpinUp     = 1;
info.flags.loadSpinUp   = 0;
info.flags.genCode      = 1;
info.flags.runGenCode   = 1;
info.flags.saveStates   = 0; %not needed? we have 'info.variables.saveStates'

% checks...

% how to do the spinUp
info.spinUp.cycleMSC    = 1;
info.spinUp.wPools      = 5;    % number of cycles until w pools in equilibrium
info.spinUp.cPools      = 2000; % number of cycles until c pools in equilibrium
% variables related to temporal scale / dimensions and stuff
info.timeScale.timeStep	= 1;    % in days
info.timeScale.nYears	= Inf;  % just a dummy
% number of iterations in tem
info.temSteps           = 1;    % number of iterations in the tem
% how / what to output
info.outputs.save       = {};   % variable names to save in files
info.outputs.saveSpinUp	= {};   % variable names to save in files
info.outputs.SpinUpVars	= {};   % variable names to output in memory
%% conflicts in setup
if isempty(info.outputs.save) && info.temSteps > 1
    error('if stemSteps > 1 intermediate model outputs should be saved...')
end
%% attribute info data from inputs
for i = 1:2:nargin
    eval(['info.' varargin{i} ' = varargin{i+1};'])
end
%% remove any spaces from experimentName
ndx	= strfind(info.experimentName,' ');
if ~isempty(ndx)
    info.experimentName = strrep(info.experimentName,' ','');
    disp(['temInfo : removing any white spaces in experimentName! info.experimentName = ' info.experimentName])
end

%% some more additional settings that depend on the inputs as well...
% time scale variables
info.timeScale.stepsPerDay	= 1 / info.timeScale.timeStep;
info.timeScale.stepsPerYear	= 365.25 / info.timeScale.timeStep;
% paths and things
info.paths.run      = strrep(info.paths.core,['model' filesep 'core'],['runs' filesep info.experimentName]);
info.paths.genCode	= [info.paths.run 'modelCode' filesep];
% restart files
info.SpinUpFile     = [info.paths.run 'output' filesep 'restart.mat'];

end % function




%{
simple(cmip5)
cVeg
cLitter
cSoil

cLeaf
cWood
cRoot
cMisc - Carbon Mass in Other Living Compartments on Land
cCwd
cLitterAbove
cLitterBelow
cSoilFast - fast is meant as lifetime of less than 10 years for  reference climate conditions (20 C, no water limitations).
cSoilMedium - medium is meant as lifetime of more than than 10 years and less than 100 years for  reference climate conditions (20 C, no water limitations)
cSoilSlow - fast is meant as lifetime of more than 100 years for  reference climate conditions (20 C, no water limitations)
%}

