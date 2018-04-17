function [f,fe,fx,s,d,p,precOnceData,sSU,dSU] = runTEM(f,info,varargin)
% Terrestrial Ecosystem Model of SINDBAD
% 
% types of calls
% minimal
%   varargout = runTEM(f,info)
%       f       : structure with the required forcing data
%       info    : structure on how to run the model
% 
% variant #1 
%   varargout   = runTEM(f,info,SUData)
%       ... same as above +
%       SUData  : structure with the subfields "sSpinUp" and "dSpinUp"
%               which will be the initial conditions of the model if the
%               flag info.tem.spinup.flags.runSpinup = false
% 
% variant #2
%   varargout   = runTEM(f,info,SUData,precOdata)
%       ... same as above +
%       precOnceData    : structure with the subfields "fx", "fe", "d" and
%                       "s" as coming out of the runCoreTEM precompute ONCE
% 
% variant #3
%   varargout	= runTEM(f,info,SUData,precOnceData,fx,fe,d,s)
%       ... same as above +
%       fx	: initialized structure for fluxes
%       fe  : initialized structure for forcing extra
%       d   : initialized structure for diagnostics
%       s   : initialized structure for states
% 
% variant #4
%   varargout	= runTEM(f,info,SUData,precOnceData,fx,fe,d,s, ...
%               fSU)
%       ... same as above +
%       fSU         : structure with the required forcing data for the
%                   spinup
%       infoSpin	: info for the spinup (analogous to info for TEM)
% 
% variant #5
%   varargout	= runTEM(f,info,SUData,precOnceData,fx,fe,d,s, ...
%               fSU,infoSpin,fxSU,feSU,dSU,sSU)
%       ... same as above +
%       fxSU	: initialized structure for fluxes during spinup
%       feSU	: initialized structure for forcing extra during spinup
%       dSU     : initialized structure for diagnostics during spinup
%       sSU     : initialized structure for states during spinup
% 
%       NOTE    : this should be the version used during optimization. One
%               can also run it like runTEM(f,info) ... but will give MSGs
%               for inneficiency
% 
%% ------------------------------------------------------------------------
% 1 - check TEM inputs
% -------------------------------------------------------------------------
% minimum requirements...
narginchk(2,14)

% get the inputs
inVarNames  = {'SUData','precOnceData','fx','fe','d','s',...
            'fSU','infoSU','precOnceDataSU','fxSU','feSU','dSU','sSU'};
for i = 1:numel(varargin);eval([inVarNames{i} ' = varargin{i};']);end

% flags needed to run the runTEM
runFlags.initialize     = false;
runFlags.precompOnce	= false;

% check the need for initialization
requirInitVars = {'fx','fe','d','s'};
if sum(cellfun(@(x)exist(x,'var'),requirInitVars)) < numel(requirInitVars)
	runFlags.initialize	= true;
end
%% ------------------------------------------------------------------------
% 2 - MODEL PARAMETERS
% -------------------------------------------------------------------------
disp('this needs checking because p becomes an output...')
p	= info.tem.params;
%% ------------------------------------------------------------------------
% 3 - SPIN UP THE MODEL
% -------------------------------------------------------------------------
% if the required inputs for spin up don't exist as inputs to the runTEM
% generate as empy
vars4spinup = {'SUData','fSU','infoSU','precOnceDataSU',...
            'fxSU','feSU','dSU','sSU'};
for v = vars4spinup
    if~exist(v{1},'var')
        eval([v{1} ' = [];']);
    end
end
% run always spinup. how to do it is decided internally
[sSU,dSU]	= runSpinupTEM(f,info,SUData,fSU,infoSU,precOnceDataSU,...
            fxSU,feSU,dSU,sSU);
%% ------------------------------------------------------------------------
% 4 - initialize TEM structures
% -------------------------------------------------------------------------
if runFlags.initialize
	if info.tem.model.flags.optiRun
		disp(['MSG : runTEM :' ...
			' optiRun == ' num2str(info.tem.model.flags.optiRun) ...
			' but no initialized variables are provided : '
			' issue of inefficiency...'])
        disp('MSG : runTEM : initializing variables ...')
	end
	[fe,fx,s,d]	= initTEMStruct(info);
end
%% ------------------------------------------------------------------------
% 5.0 - RUN THE MODEL
% -------------------------------------------------------------------------
for iStep = 1:info.temSteps
    % this is where we can change the way to run the model, like, loading
    % data for every year (useful for large runs)
    % ---------------------------------------------------------------------
    % 5.1 - PRECOMPUTATIONS (ONCE)
    % ---------------------------------------------------------------------
    if ~exist('precOnceData','var')
        [f,fe,fx,s,d,p] = runCoreTEM(f,fe,fx,s,d,p,info,true,false,false);
        for v = {'f','fe','fx','s','d','p'}
            eval(['precOnceData.(i{1})	= ' v{1} ';']);
        end
    else
        for v = {'f','fe','fx','s','d','p'}
            eval([v{1} ' = precOnceData.(i{1});']);
        end
    end
	
    % ---------------------------------------------------------------------
    % 5.2 - CARBON AND WATER DYNAMICS IN THE ECOSYSTEM: FLUXES AND STATES
    % ---------------------------------------------------------------------
	[f,fe,fx,s,d,p]   = runCoreTEM(f,fe,fx,s,d,p,info,false,true,false);
    % ---------------------------------------------------------------------
    % ?.? - DO WE AGGREGATE STATES AND CHECK BALANCES HERE AND WRITE OUTPUT
    % ---------------------------------------------------------------------
end
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