function ()
% SINDBAD Terrestrial Ecosystem Model - currently we call it CASA
% 
% DESCRIPTION:
% 
% INPUTS:
% 
% CONTRIBUTORS:
% 
% CONTACT:

%% 




% -------------------------------------------------------------------------
% 1 - MODEL SETTINGS
% -------------------------------------------------------------------------

% insert flag if is optimization mode or forward model run

% forcing - climate, fpar, ...
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
	info.etmodel = @calc_et_mj;
    
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

%% 
% -------------------------------------------------------------------------
% 3 - MODEL PARAMETERS
% -------------------------------------------------------------------------

% load model parameters
	% if in optimization mode, load the standard parametrization and
	% multiply the delta_parameters * parameter_standard
		% check if parameters are within accepted bounds (or should this be
		% done outside?) 
        
        
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
	p.et.alpha = inip.et.alpha .* scalp.et.alpha;


% -------------------------------------------------------------------------
% 5 - RUN THE MODEL
% -------------------------------------------------------------------------

% initialize model states
    % carbon and water pools


% LOOP 1 : BIG loop spin-up, second spin-up, transient

    % ---------------------------------------------------------------------
    % 5.1. - SETUP SPIN-UP /TRANSIENT RUNS
    % ---------------------------------------------------------------------
	% here it is checked if we are in spin-up or transient mode
		% organize forcing
			% spin-up
			% spin-up 2
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
	
    % ---------------------------------------------------------------------
    % 6. - CARBON AND WATER DYNAMICS IN THE ECOSYSTEM
    % ---------------------------------------------------------------------
    
	% LOOP 2 : loop years
        
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
        
        % -----------------------------------------------------------------
        % 6.3. - COMPUTE FLUXES AND STATES
        % -----------------------------------------------------------------
        
        % we "outsource" the actual run to make it easier for development
        % if spin-up or transient
		
			% 2D -> (space,time)
		
            [fx,s,d] = core(s, f, p, settings/options);
            
        % if spin-up 2 (the forcing of this function is actually the
        % stressors in the diagnostics structure)
            [s] = calc_cflux_fast(s, p, d);
        

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

    % LOOP END - years
% LOOP END - big loop

% -------------------------------------------------------------------------
% 7 - GLOBAL OUTPUTS
% -------------------------------------------------------------------------

% like before, outputs for file or memory in transient mode (note, this way
% should also have the option to be consistent with the previous CASA code
% output, so that the optimization algorithms can be used with minimal
% adjustments) -> this can be outsourced to a function for making the code
% easier to read.


