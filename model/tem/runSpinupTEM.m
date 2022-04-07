function [fSU,feSU,fxSU,precOnceDataSU,sSU,dSU,infoSU] = runSpinupTEM(f,info,p,SUData,fSU,infoSU,...
        precOnceDataSU,fxSU,feSU,dSU,sSU)
% runs the spinup of SINDBAD
%
% Requires:
%   - variant 1 (Minimal) : varargout = runSpinupTEM(f,info)
%       - f : structure with the required full forcing data (from which fSU
%       will be created, if needed)
%       - info : structure on how to run the model (from which infoSU will
%       be created)
%   - variant 2 : varargout   = runSpinupTEM(f,info,p)
%       - same as 1, and
%       - p: parameter structure (for e.g., from optimizer)
%   - variant 3 : varargout = runSpinupTEM(f,info,p,SUData)
%       - same as 2, and
%       - SUDATA : structure with the subfields "sSU" and "dSU"
%               which will be the initial conditions of the model if the
%               flag info.tem.spinup.flags.runSpinup = false
%   - variant 4 : varargout = runSpinupTEM(f,info,p,SUData,fSU)
%       - same as 3, and
%       - fSU: The forcing for spinup which has been precreated. Especially
%       useful when in optimization mode and the data does not need to be
%       created in every iteration.
%   - variant 5 : varargout = runSpinupTEM(f,info,p,SUData,fSU,infoSU)
%       - same as 4, and
%       - infoSU: A copy of info in which the fields related to time (nTix) and year have been modified to match those for spinup
%   - variant 6 : varargout = runSpinupTEM(f,info,p,SUData,fSU,infoSU,precOnceDataSU)
%       - same as 5, and
%       - precOnceDataSU : structure with the subfields "fx", "fe", "d" and
%                       "s" as coming out of the runCoreTEM with
%                       doPrecOnce. Contains the variables that can be
%                       computed outside the time loop.
%   - variant 7 : varargout = runSpinupTEM(f,info,p,SUData,fSU,infoSU,precOnceDataSU,fxSU,feSU,dSU,sSU)
%       - same as 6, and
%       - fxSU : initialized structure for fluxes with pre-created arrays for spinup
%       - feSU : initialized structure with pre-calculated extra forcing for spinup
%       - dSU : initialized diagnostic structure with pre-created arrays for spinup
%       - sSU : initialized state structure wtih with pre-created arrays for spinup
%
% Purposes:
%   - returns fSU,feSU,fxSU,precOnceDataSU,sSU,dSU,infoSU after running the
%   coreTEM and precOnce for spinup
%
% Conventions:
%  - selects the original handle or generated code based on info.tem.model.flags.runGenCode
%       - if true, runs generated code for both coreTEM and preconce and core
%       - if false,
%           - runs original original handle of coreTEM and runPrecOnceTEM for forward run
%           - runs coreTEM4Spinup and runPrecOnceTEM for spinup (subset of
%           modules selected through use4spinup flag in
%           modelStructure.json.
%
% Created by:
%   - Nuno Carvalhais (ncarval)
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.1 on 10.07.2018 : includes functionalities of use4spinup
%   - 1.0 on 01.05.2018

%%
%% ------------------------------------------------------------------------
% 1 - LOAD THE SPINUP FROM MEMORY OR FROM RESTART FILE
% -------------------------------------------------------------------------
if info.tem.spinup.flags.loadSpinup
    % load the spinup file "restart.mat" inside the run path
    load(info.tem.spinup.paths.restartFile)
    % this needs to output sSU and dSU
    if sum(strcmp(who,'sSU')) ~= 1 || sum(strcmp(who,'dSU')) ~= 1
        err([pad('ERR SPINUP',20) ' : ' pad('runSpinupTEM',20) ' | restart file does not have sSU or dSU fields'])
    end
    disp([pad('DATA SPINUP',20) ' : ' pad('runSpinupTEM',20) ' | loaded sSU and dSU from restart file'])
    return
elseif~info.tem.spinup.flags.runSpinup
    % in this case we need to have SUData
    if ~isempty(SUData)
        if ~isempty(SUData.sSU) && ~isempty(SUData.dSU)
            % get the initial conditions from memory
            sSU    = SUData.sSU;
            dSU    = SUData.dSU;
            disp([pad('DATA SPINUP',20) ' : ' pad('runSpinupTEM',20) ' : loaded SUData.sSU and SUData.dSU from memory!'])
        else
            err([pad('DATA SPINUP',20) ' : ' pad('runSpinupTEM',20) ' : runSpinup is false in modelRun config, and cannot read it from file or memory!'])
        end
    end
    return
end
%% ------------------------------------------------------------------------
% 2 - RUN THE SPINUP
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% check whether there is the need to initialize stuff
% -------------------------------------------------------------------------
runFlags.createStruct = false;
requirInitVars      = {'fxSU','feSU','dSU','sSU'};
if sum(cellfun(@(x)exist('x','var') && ~isempty(evalin('caller',x)),requirInitVars)) < numel(requirInitVars)
    runFlags.createStruct    = true;
end
% -------------------------------------------------------------------------
% Make the spinup data - only if it is an empty input
% -------------------------------------------------------------------------
if isempty(fSU), fSU    = prepSpinupForcing(f,info); end
% -------------------------------------------------------------------------
% Adjust the info structure - only if it is an empty input
% -------------------------------------------------------------------------
if isempty(infoSU)
    % make a new info for spin up based on info...
    infoSU    = info;
    % adjust the nTix
    tmpFN                     = fieldnames(fSU);
    newNTix                 = size(fSU.(tmpFN{1}),2);
    infoSU.tem.helpers.sizes.nTix    = newNTix;
    if info.tem.spinup.flags.recycleMSC
        infoSU.tem.model.nYears    = 1; % should come from info.tem.s
    end
    
    % TINA: add dates.day from fSU.dates if it exists
    try
        infoSU.tem.helpers.dates.day      =  fSU.dates.day;
    end
    
end
% -------------------------------------------------------------------------
% Pre-allocate fx,fe,d,s for the spinup runs
% -------------------------------------------------------------------------
if runFlags.createStruct
    [feSU,fxSU,sSU,dSU,infoSU]    = createTEMStruct(infoSU);
end
% -------------------------------------------------------------------------
% the parameters
% -------------------------------------------------------------------------
pSU    = p;
% -------------------------------------------------------------------------
% get the precOnce data structure
% -------------------------------------------------------------------------
[precOnceDataSU,fSU,feSU,fxSU,sSU,dSU,pSU] = setPrecOnceData(precOnceDataSU,fSU,feSU,fxSU,sSU,dSU,pSU,infoSU,'runSpinupTEM');

% -------------------------------------------------------------------------
% complete spinup sequence
% -------------------------------------------------------------------------
if isfield(dSU,'storedStates') && isfield(dSU.storedStates,'cEco') && info.tem.spinup.flags.storeFullSpinupStates
% if isfield(dSU.storedStates,'cEco') && info.tem.spinup.flags.storeFullSpinupStates
    tmpLS                   = dSU.storedStates.cEco;
end

spinSequence = info.tem.spinup.sequence;
for iss = 1:numel(spinSequence)
    % get handles, inputs and number of loops
    funHandleSpin    = str2func(spinSequence(iss).funHandleSpin);
    addInputs       = spinSequence(iss).funAddInputs;
    nLoops          = spinSequence(iss).nLoops;
    if ~iscell(addInputs),addInputs = num2cell(addInputs');end
    disp([pad('EXEC MODRUN',20,'right') ' : ' pad('runSpinupTEM',20) ' | ' pad('sequence',8) ' : ' num2str(iss) ' / ' num2str(numel(spinSequence)) ' | funHandleSpin    : ' spinSequence(iss).funHandleSpin])
    if ~isempty(spinSequence(iss).funHandleStop)
        funHandleStop   = str2func(spinSequence(iss).funHandleStop);
    else
        funHandleStop   = spinSequence(iss).funHandleStop;
    end
    % go for it
    for ij = 1:nLoops
        % run spinup
        disp(pad('.',200,'both','.'))
        disp([pad('EXEC MODRUN',20,'left') ' : ' pad('runSpinupTEM',20) ' | ' pad('nLoop',8) ' : ' num2str(ij) ' / ' num2str(spinSequence(iss).nLoops)])
        [fSU,feSU,fxSU,sSU,dSU,pSU]    = ...
            funHandleSpin(fSU,feSU,fxSU,sSU,dSU,pSU,infoSU,addInputs{:});
        % stop it according to function criteria?
        if ~isempty(funHandleStop)
            % true is stop now, false continues
            if funHandleStop(fSU,feSU,fxSU,sSU,dSU,pSU,infoSU)
                break
            end
        end
        %%
        disp(pad('-',50,'both','-'))
        if isfield(sSU,'prev')
            if isfield(sSU.prev,'s_c_cEco')
                
                disp([pad('cCycle DEBUG',20) ' : ' pad('runSpinupTEM:',20) 'with previous s.c.cEco'])
                disp(pad('-',5,'left'))
                disp(cell2table(num2cell([round(sSU.c.cEco(1,:),2);round(sSU.prev.s_c_cEco(1,:),2)]), 'VariableNames', info.tem.model.variables.states.c.components', 'RowNames',{'Current', 'Previous'}))
%                 disp(num2str([1:size(sSU.c.cEco,2);round(sSU.c.cEco(1,:),2);round(sSU.prev.s_c_cEco(1,:),2)]))
            elseif isfield(sSU,'c')
                disp([pad('cCycle DEBUG',20) ' : ' pad('runSpinupTEM:',20)])
                disp(pad('-',5,'left'))
                disp(cell2table(num2cell(round(sSU.c.cEco(1,:),2)), 'VariableNames', info.tem.model.variables.states.c.components', 'RowNames',{'Current'}))
            end
        end
        
        if ~exist('tmpLS','var') && isfield(dSU,'storedStates') && isfield(dSU.storedStates,'cEco') && info.tem.spinup.flags.storeFullSpinupStates
            tmpLS                   = dSU.storedStates.cEco;
        elseif isfield(dSU,'storedStates') && isfield(dSU,'storedStates') && isfield(dSU.storedStates,'cEco') && info.tem.spinup.flags.storeFullSpinupStates
            tmpLS = cat(3,tmpLS,dSU.storedStates.cEco);
        end
    end
end
if isfield(dSU,'storedStates') && isfield(dSU,'storedStates') && isfield(dSU.storedStates,'cEco') && info.tem.spinup.flags.storeFullSpinupStates
    dSU.fullSpinupStates.cEco = tmpLS;% @nc: to delete or adjust
end

end
