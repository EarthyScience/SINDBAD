function [f,fe,fx,s,d,p,precOnceData,sSU,dSU] = runTEM(info,f,varargin)
% Terrestrial Ecosystem Model of SINDBAD
%
% types of calls
% minimal
%   varargout = runTEM(info,f)
%       f       : structure with the required forcing data
%       info    : structure on how to run the model
%
% variant #1
%   varargout   = runTEM(info,f,SUData)
%       ... same as above +
%       SUData  : structure with the subfields "sSpinUp" and "dSpinUp"
%               which will be the initial conditions of the model if the
%               flag info.tem.spinup.flags.runSpinup = false
%
% variant #2
%   varargout   = runTEM(info,f,SUData,precOdata)
%       ... same as above +
%       precOnceData    : structure with the subfields "fx", "fe", "d" and
%                       "s" as coming out of the runCoreTEM precompute ONCE
%
% variant #3
%   varargout	= runTEM(info,f,SUData,precOnceData,fx,fe,d,s)
%       ... same as above +
%       fx	: initialized structure for fluxes
%       fe  : initialized structure for forcing extra
%       d   : initialized structure for diagnostics
%       s   : initialized structure for states
%
% variant #4
%   varargout	= runTEM(info,f,SUData,precOnceData,fx,fe,d,s, ...
%               fSU)
%       ... same as above +
%       fSU         : structure with the required forcing data for the
%                   spinup
%       infoSpin	: info for the spinup (analogous to info for TEM)
%
% variant #5
%   varargout	= runTEM(info,f,SUData,precOnceData,fx,fe,d,s, ...
%               fSU,infoSpin,fxSU,feSU,dSU,sSU)
%       ... same as above +
%       fxSU	: initialized structure for fluxes during spinup
%       feSU	: initialized structure for forcing extra during spinup
%       dSU     : initialized structure for diagnostics during spinup
%       sSU     : initialized structure for states during spinup
%
%       NOTE    : this should be the version used during optimization. One
%               can also run it like runTEM(info,f) ... but will give MSGs
%               for inneficiency
%
%% ------------------------------------------------------------------------
% 1 - check TEM inputs
% -------------------------------------------------------------------------
% minimum requirements...
% narginchk(2,14)

%--> sujan: parser of pairwise varargin
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
    errorMsg= ['runTEM has optional input arguments in pairs with the following variables :' ...
        'SUData, ','precOnceData, ','fx, ','fe, ','d, ','s, ','p, ', ...
        'fSU, ','infoSU, ','precOnceDataSU, ','fxSU, ','feSU, ','dSU, ','sSU'];
    error(errorMsg)
end

inVarsAccepted      =   {'SUData','precOnceData','fx','fe','d','s','p'...
    'fSU','infoSU','precOnceDataSU','fxSU','feSU','dSU','sSU'};

for datPair     =   reshape(varargin,2,[]) % datPair is {varName:varData}
    inpName      =   datPair{1};
    eval([inpName ' = datPair{2};'])
    if ~any(strcmp(inpName,inVarsAccepted))
        error('%s is not a recognized variable of runTEM',inpName)
    end
end
%<-- parser of pairwise varargin

%sujan replaced the following with the above pair-wise
% % get the inputs
%
% % inVarNames  = {'fx','fe','d','s','precOnceData','SUData',...
% %             'fSU','infoSU','fxSU','feSU','dSU','sSU','precOnceDataSU'};
% for i                   =   1:numel(varargin);eval([inVarNames{i} ' = varargin{i};']);end

% flags needed to run the runTEM renamed runFlags.initialize to
% runFlags.createStruct --> %sujan: might be better to put this flag as an
% input to TEM to make sure that when runTEM is called during optimization
% the objects and arrays are not always created

runFlags.createStruct       =   false;
runFlags.precompOnce        =   false;

% check the need for creating sindbad objects and arrays therein
requirInitVars              =   {'fx','fe','d','s'};
if sum(cellfun(@(x)exist(x,'var'),requirInitVars)) < numel(requirInitVars)
    runFlags.createStruct	=   true;
end
%% ------------------------------------------------------------------------
% 2 - MODEL PARAMETERS
% -------------------------------------------------------------------------
disp('this needs checking because p becomes an output...')
if ~exist('p','var')
    p                           =   info.tem.params;
end
% should I avoid creating  at any time?

%%
% ------------------------------------------------------------------------
% 3 - SPIN UP THE MODEL
% -------------------------------------------------------------------------
%--> if the required inputs for spin up don't exist as inputs to the runTEM
% generate as empty
vars4spinup             =   {'SUData','fSU','infoSU','precOnceDataSU',...
    'fxSU','feSU','dSU','sSU'};
for v   =	vars4spinup
    if  ~exist(v{1},'var')
        eval([v{1} ' = [];']);
    end
end
% ----------------------------------------------------------------------------------------------
%--> The SINDBAD is setup to always run a spinup.
%    The rules for spinup and sequence are taken from spinup.json inside runSpinupTEM.
%    The SINDBAD structures needed for spinup as per the size of spinup
%    forcing is generated in there as well.
%<--
% -----------------------------------------------------------------------------------------------

[sSU,dSU]               =   runSpinupTEM(f,info,p,SUData,fSU,infoSU,precOnceDataSU,...
    fxSU,feSU,dSU,sSU);

%% ------------------------------------------------------------------------
% 4 - createStruct TEM structures
% -------------------------------------------------------------------------
if runFlags.createStruct 
    disp('MSG : runTEM : creating SINDBAD objects and arrays ...')
    [fe,fx,s,d,info]     =  createTEMStruct(info); %sujan
    % should we set the runFlags.createStruct to false? %sujan
        %--> the following might be unnecessary %sujan
        if info.tem.model.flags.runOpti
            disp(['MSG : runTEM :' ...
                ' optiRun == ' num2str(info.tem.model.flags.runOpti) ...
                ' but created SINDBAD objects with arrays are not provided : '...
                ' The arrays will be created in every iteration of optimization'...
                ' Extremely inefficient mode of running...'])
        end
end

disp('MSG : Spinup of runTEM : replacing default s and d.prev with Spinup output ...')
% feed the end states of spinup to the initial condition of the forward
% model run
%% spinup data
if ~isempty(sSU), s=sSU; end
if isempty(dSU), dSU = d; end
if isfield(dSU,'prev')
    d.prev       =  dSU.prev;
end



%% ------------------------------------------------------------------------
% 5.0 - RUN THE MODEL
% -------------------------------------------------------------------------
% for iStep = 1%:info.tem.model.time.nStepsDay %sujan need to handle this
    % this is where we can change the way to run the model, like, loading
    % data for every year (useful for large runs)
    % ---------------------------------------------------------------------
    % 5.1 - PRECOMPUTATIONS (ONCE)
    % ---------------------------------------------------------------------
    if ~exist('precOnceData','var')
        [f,fe,fx,s,d,p] = runCoreTEM(f,fe,fx,s,d,p,info,true,false,false); %sujan make sure to replace this with runPrecOnceTEM --> nuno
        for v = {'f','fe','fx','s','d','p'}
            eval(['precOnceData.(v{1})	= ' v{1} ';']);
        end
    else
        for v = {'f','fe','fx','d','p'}
            eval([v{1} ' = precOnceData.(v{1});']);
            if strcmp(v{1},'d') %&& iStep == 1
                d.prev       =  dSU.prev;
            end
        end
    end
    
    % ---------------------------------------------------------------------
    % 5.2 - CARBON AND WATER DYNAMICS IN THE ECOSYSTEM: FLUXES AND STATES
    % ---------------------------------------------------------------------
    [f,fe,fx,s,d,p]   = runCoreTEM(f,fe,fx,s,d,p,info,false,true,false);
    % ---------------------------------------------------------------------
    % ?.? - DO WE AGGREGATE STATES AND CHECK BALANCES HERE AND WRITE OUTPUT
    % ---------------------------------------------------------------------
% end
end % function

%%
% -------------------------------------------------------------------------
% 1 - MODEL SETTINGS
% -------------------------------------------------------------------------

% insert flag if is optimization mode or forward model run
% info.flags.opti

% forcing - climate, fpar, ...

% check the units

% parameter - controls response functions of model structure
% surface variables
% soil
% vegetatioon
% estimates of memory checks



% load the model settings
% how to do the spinup
% how to compute fpar
% which GPP/W coupling scheme to use
% compute diagnostics
% working in optimization mode?
% check surface properties
% ... (etc)
% eg of a handle function for the calculation of et


%{
    % -------------------------------------------------------------------------
% 4 - CONSISTENCY CHECKS
% -------------------------------------------------------------------------

% consistency checks in the way to run the model and the needed variables
    % we need a time stamp vector in there now!

% check compatibility with the settings, the forcing and the parameters

% here end of if optimization or not

% if it is in optmization mode , we need a flag that says if we need to scale the paraetmers
	% scale paraemtres
% 	p.et.alpha = inip.et.alpha .* scalp.et.alpha;


    old notes...
% -------------------------------------------------------------------------
% 2 - IO SETUP
% -------------------------------------------------------------------------

% flags for input-output (io) operations
	% from memory or from files?
		% depending on the forcing (f) input. Folder names means from
		% files, matrices means memory
	% output
		% save spin-up results?
		% save transient simulations outputs?
		% save diagnostics
		% how to save them? every day? month? year?
	% messages on model running
		% ignore messages
		% display messages during model run
		% save them in an output file somewhere
	% restart files?
	%

            % -----------------------------------------------------------------
        % 6.1. - DEAL WITH MODEL FORCING
        % -----------------------------------------------------------------
        
        % switch
            % load from file
                % spin up
                    % we only need to load it once
                % transient
                    % get the file named as the year
                    
            % load from memory
                % spin up
                    % adjust time vector every year (we are basically
                    % repeating the same year over and over...
                % transient
                    % sample the yearly data from the complete time series
                    % (we always assume that from memory, we have all the
                    % data at the same time)
        % -----------------------------------------------------------------
        % 6.2. - EXTRA FORCING REQUIREMENTS -this should be up!!!
        % -----------------------------------------------------------------
        
        % special forcing, like soil temperature, PET, l?l?l? - this can be
        % fed into the forcing structure
        

% -------------------------------------------------------------------------
% 7 - GLOBAL OUTPUTS
% -------------------------------------------------------------------------

% like before, outputs for file or memory in transient mode (note, this way
% should also have the option to be consistent with the previous CASA code
% output, so that the optimization algorithms can be used with minimal
% adjustments) -> this can be outsourced to a function for making the code
% easier to read.
    
        % do the aggregation of the cPools here
    if info.tem.flags.saveStates >= 1 || info.checks.CBalance
        d	= temAggStates(info,d);
    end
    
    % ---------------------------------------------------------------------
    % X.X - CHECK BALANCES
    % ---------------------------------------------------------------------
    info	= CheckCarbonBalance(f,fe,fx,s,d,p,info);
    info	= CheckWaterBalance(f,fe,fx,s,d,p,info);
    
    
    % -----------------------------------------------------------------
    % 6.4. - OUTPUTS
    % -----------------------------------------------------------------
        

    % outputs for file or memory in transient mode (note, this way
    % should also have the option to be consistent with the previous
    % CASA code output, so that the optimization algorithms can be used
    % with minimal adjustments)

    % deal with restart files and have everything ones needs just to
    % restart where we left from
    
    disp('between these comments need revision - stop')
    

% % ---------------------------------------------------------------------
% % save the spinup output?
% % ---------------------------------------------------------------------
% if ~isempty(info.outputs.saveSpinUp)
% end


%}