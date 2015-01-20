function varargout = tem(f,info,SUData)
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

% here end of if optimization or not

% if it is in optmization mode , we need a flag that says if we need to scale the paraetmers
	% scale paraemtres
% 	p.et.alpha = inip.et.alpha .* scalp.et.alpha;

% -------------------------------------------------------------------------
% 5 - SPIN UP THE MODEL
% -------------------------------------------------------------------------
% do the SpinUp
if~exist('SUData','var');SUData=[];end
[sSU,dSU]   = doSpinUp(f,p,info,SUData);
        
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
            [fe,fx,d,p] = info.code.preComp(prc).fun(f,fe,fx,s,d,p,info);
        end
    end

	
    % ---------------------------------------------------------------------
    % 5.2 - CARBON AND WATER DYNAMICS IN THE ECOSYSTEM: FLUXES AND STATES
    % ---------------------------------------------------------------------
    [fx,s,d] = core(f,fe,fx,s,d,p,info);
    
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

if nargout >= 3
    varargout{1} = fx;
    varargout{2} = s;
    varargout{3} = d;
end

if nargout >= 5
    varargout{4} = sSU;
    varargout{5} = dSU;
end



% -------------------------------------------------------------------------
% 7 - GLOBAL OUTPUTS
% -------------------------------------------------------------------------

% like before, outputs for file or memory in transient mode (note, this way
% should also have the option to be consistent with the previous CASA code
% output, so that the optimization algorithms can be used with minimal
% adjustments) -> this can be outsourced to a function for making the code
% easier to read.


