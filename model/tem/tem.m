function varargout = tem(f,info)
% Terrestrial Ecosystem Model of SINDBAD
% 
% DESCRIPTION:
% 
% INPUTS:
% fSpin
% f
% 
% CONTRIBUTORS:
% 
% CONTACT:
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

    
%% 
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
        
        % special forcing, like soil temperature, PET, lálálá - this can be
        % fed into the forcing structure
        


    
%% 
% -------------------------------------------------------------------------
% 3 - MODEL PARAMETERS
% -------------------------------------------------------------------------
% NO!! THIS NEEDS TO BE TAKEN CARE BEFORE AND ONLY DONE IF THE RunFlag==0
% load model parameters
	% if in optimization mode, load the standard parametrization and
	% multiply the delta_parameters * parameter_standard
		% check if parameters are within accepted bounds (or should this be
		% done outside?) 

p   = info.params;
        
        
%% 
% -------------------------------------------------------------------------
% 4 - CONSISTENCY CHECKS
% -------------------------------------------------------------------------

% consistency checks in the way to run the model and the needed variables
    % we need a time stamp vector in there now!

% check compatibility with the settings, the forcing and the parameters

%% 


% here end of if optimization or not

% if it is in optmization mode , we need a flag that says if we need to scale the paraetmers
	% scale paraemtres
% 	p.et.alpha = inip.et.alpha .* scalp.et.alpha;

% -------------------------------------------------------------------------
% 5 - SPIN UP THE MODEL
% -------------------------------------------------------------------------

    % ---------------------------------------------------------------------
    % 5.1. - SETUP SPIN-UP /TRANSIENT RUNS
    % ---------------------------------------------------------------------
	% here it is checked if we are in spin-up or transient mode
%     switch wstep
% 		% organize forcing
%         case 1 % SpinUp the model
% 			% spin-up for NPP and soil water pools
% 
% 			% spin-up 2
%             [s] = calc_cflux_fast(s, p, d);
				% we just need the stressors
			% transient
		% initial model states
			% spin-up
				% initialize model states
			% spin-up 2
			% transient
				% adjust states? how? (NO! This should be used inside the
				% core!!)
        % set up the looping variables
        
        
        
if info.flags.doSpinUp
    % ---------------------------------------------------------------------
    % Make the spinup data - this should be done before?
    % ---------------------------------------------------------------------
    fSU	= mkSpinUpData(f,info);
    
    % ---------------------------------------------------------------------
    % Adjust the info structure
    % ---------------------------------------------------------------------
    infoSpin                    = info;
    infoSpin.forcing.size(2)    = floor(info.timeScale.stepsPerYear);
    infoSpin.timeScale.nYears   = 1;
    
    % ---------------------------------------------------------------------
    % Pre-allocate fx,fe,d,s for the spinup runs
    % ---------------------------------------------------------------------
    [fxSU,feSU,dSU,sSU]	= initTEMStruct(infoSpin);

    % ---------------------------------------------------------------------
    % Precomputations
    % ---------------------------------------------------------------------
    for prc = 1:numel(infoSpin.code.preComp)
        tmp                 = infoSpin.code.preComp(prc).fun;     % no idea why this way
        [feSU,fxSU,dSU,p]	= tmp(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);  % works but not inline
    end
    
    % ---------------------------------------------------------------------
    % run the model for spin-up for NPP and soil water pools @ equilibrium
    % ---------------------------------------------------------------------
    for ij = 1:info.spinUp.wPools
        [sSU, fxSU, dSU] = core(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
    end
    
    % ---------------------------------------------------------------------
    % run the model for spin-up for soil C pools @ equilibrium
    % ---------------------------------------------------------------------
    if~isempty(strmatch(info.approaches,'CCycle_CASA','exact'))
        [fxSU,sSU,dSU]	= CASA_fast(fSU,feSU,fxSU,sSU,dSU,p,infoSpin);
    elseif isempty(strmatch(info.approaches,'CCycle_none','exact'))
        error(['No spinUp definition for current setup'])
    end
    
    % ---------------------------------------------------------------------
    % save the spinup output?
    % ---------------------------------------------------------------------
    if ~isempty(info.outputs.saveSpinUp)
    end
else
    % ---------------------------------------------------------------------
    % steady state pools have to loaded from memory or from a restart file
    % ---------------------------------------------------------------------
    if info.flags.loadSpinUp
        % load the spinup file "restart.mat" inside the run path
        
    elseif ~isempty(info.spinUp.sSpinUp) && ~isempty(info.spinUp.dSpinUp)
        % get the initial conditions from memory
        sSU	= info.spinUp.sSpinUp;
        dSU	= info.spinUp.dSpinUp;
    else
        error('what to do for the spin up?!')
    end
end

% get initial conditions for the model run
[fx,fe,d,s]	= initTEMStruct(info,sSU,dSU);

% -------------------------------------------------------------------------
% 5.0 - RUN THE MODEL
% -------------------------------------------------------------------------
for iStep = 1:info.temSteps
    % this is where we can change the way to run the model, like, loading
    % data for every year (useful for large runs), prescribe land cover
    % changes, ................
    
    % ---------------------------------------------------------------------
    % 5.1 - PRECOMPUTATIONS
    % ---------------------------------------------------------------------
    for prc = 1:numel(info.code.preComp)
        if info.code.preComp(prc).doAlways == 0
            tmp         = info.code.preComp(prc).fun;   % no idea why this way
            [fe,fx,d,p] = tmp(f,fe,fx,s,d,p,info);      % works but not inline
        end
    end

	
    % ---------------------------------------------------------------------
    % 5.2 - CARBON AND WATER DYNAMICS IN THE ECOSYSTEM: FLUXES AND STATES
    % ---------------------------------------------------------------------
    [s, fx, d] = core(f,fe,fx,s,d,p,info);
    
    % -----------------------------------------------------------------
    % 6.4. - OUTPUTS
    % -----------------------------------------------------------------
        
    % outputs for file in spinup mode (step 1)

    % outputs for file in spinup mode (step 2)

    % outputs for file or memory in transient mode (note, this way
    % should also have the option to be consistent with the previous
    % CASA code output, so that the optimization algorithms can be used
    % with minimal adjustments)

    % deal with restart files and have everything ones needs just to restart where we left from

end

% -------------------------------------------------------------------------
% 7 - GLOBAL OUTPUTS
% -------------------------------------------------------------------------

% like before, outputs for file or memory in transient mode (note, this way
% should also have the option to be consistent with the previous CASA code
% output, so that the optimization algorithms can be used with minimal
% adjustments) -> this can be outsourced to a function for making the code
% easier to read.


