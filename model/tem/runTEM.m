function [f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU] = runTEM(info,f,p,SUData,precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU) 
% runs the Terrestrial Ecosystem Model of SINDBAD 
%
% Requires:
%   - variant 1 (Minimal) : varargout = runTEM(info,f)
%       - f : structure with the required forcing data
%       - info : structure on how to run the model
%   - variant 2 : varargout   = runTEM(info,f,p)
%       - same as 1, and
%       - p: parameter structure
%   - variant 3 : varargout = runTEM(info,f,p,SUData)
%       - same as 2, and 
%       - SUDATA : structure with the subfields "sSU" and "dSU"
%               which will be the initial conditions of the model if the
%               flag info.tem.spinup.flags.runSpinup = false
%   - variant 4 : varargout = runTEM(info,f,p,SUData,precOnceData)
%       - same as 3, and 
%       - precOnceData : structure with the subfields "fx", "fe", "d" and
%                       "s" as coming out of the runCoreTEM with
%                       doPrecOnce. Contains the variables that can be
%                       computed outside the time loop.
%   - variant 5 : varargout = runTEM(info,f,p,SUData,precOnceData,fx,fe,d,s)
%       - same as 4, and
%       - fx : initialized structure for fluxes with pre-created arrays 
%       - fe : initialized structure with pre-calculated extra forcing
%       - d : initialized diagnostic structure with pre-created arrays
%       - s : initialized state structure wtih with pre-created arrays
%   - variant 6: varargout = runTEM(info,f,p,SUData,precOnceData,fx,fe,d,s,infoSU,fSU)
%       - same as 5, and 
%       - infoSU: a copy of info with time and other information edited to match spinup run
%       - fSU: a forcing structure with forcing variables needed to run the
%       spinup, e.g., MSC of all variables
%   - variant 7: varargout = runTEM(info,f,p,SUData,precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU)
%       - same as 6, and
%       - precOnceDataSU: Same as precOnceData but with spinup forcing
%   - variant 8: varargout = runTEM(info,f,p,SUData,precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU)
%       - same as 7, and
%       - fxSU,feSU,dSU,sSU: Same as variant 5, but with spinup forcing
% 
%
% Purposes:
%   - returns f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU
%   - All SINDBAD structures with fluxes, states, and diagnostics from 
%       - a forward run (f,fe,fx,s,d,p,precOnceData)
%       - the spinup (fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU) using spinup forcing and the selected modules for spinup 
%
% Conventions:
%   - the logic is that only mandatory inputs are info and f.
%               all the others are optional OR empty. When empty (or not
%               given) they are created.
%   - When called with minimal inputs (variant 1), the execution is slowest.
%   - For faster runs use, variant 8. For example, during optimization.
%       
% Created by:
%   - Nuno Carvalhais (ncarval@bgc-jena.mpg.de)
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% References:
%
% Versions:
%   - 1.0 on 01.05.2018 
%   - 1.1 on 01.07.2018 (bug fixes in createTEMstruct, and added display
%   for log of model run)

%% ------------------------------------------------------------------------
% 1 - check TEM inputs
% -------------------------------------------------------------------------
% minimum requirements...
tstart = tic;
minIn = 2;
maxIn = 16;
narginchk(minIn,maxIn)

% input variable names
inVarNames	= {'p','SUData','precOnceData','fx','fe','d','s',...
            'infoSU','fSU','precOnceDataSU','fxSU','feSU','dSU','sSU'};

% from last to first optional parameters, set them to [] when not included.
for i = maxIn:-1:nargin+1
    inVar = inVarNames{i-minIn};
    eval([inVar ' = [];'])
end
% for i = maxIn:-1:nargin+1
%     inVar = inVarNames{i-minIn};
%     if ~exist(inVar,'var')
% % 
% %         disp('variable exists')
% %     else
% % %         if ~isempty(eval(inVarNames{i-minIn}))
%     eval([inVar ' = [];'])
% %     end
%     end
% end

% flags needed to run the runTEM
runFlags.createStruct	=   false;
runFlags.precompOnce    =   false;

% check the need for creating sindbad objects and arrays therein
requirInitVars	= {'fx','fe','d','s'};
% sumRVars = numel(requirInitVars);
% for rv = 1:numel(requirInitVars)
%     if isempty(eval(requirInitVars{rv}))
% %     if exist(char(requirInitVars{rv}),'var')
%         sumRVars = sumRVars - 1;
%     end
% end
%  
% if sumRVars < numel(requirInitVars)
% % if sumRVars <= numel(requirInitVars)
%     runFlags.createStruct	= true;
% end
% % sujan
% if sum(cellfun(@(x)exist('x','var'),requirInitVars)) < numel(requirInitVars)
%     runFlags.createStruct	= true;
% end
if sum(cellfun(@(x)exist('x','var') && ~isempty(evalin('caller',x)),requirInitVars)) < numel(requirInitVars)
    runFlags.createStruct	= true;
end
%% ------------------------------------------------------------------------
% 2 - MODEL PARAMETERS
% -------------------------------------------------------------------------
if isempty(p)
    p	=   info.tem.params;
end
%% ------------------------------------------------------------------------
% 3 - SPIN UP THE MODEL
% -------------------------------------------------------------------------
% sujan
% [sSU,dSU]   = runSpinupTEM(f,info,p,SUData,fSU,infoSU,precOnceDataSU,...
%             fxSU,feSU,dSU,sSU);
[fSU,feSU,fxSU,precOnceDataSU,sSU,dSU,infoSU]   = runSpinupTEM(f,info,p,SUData,fSU,infoSU,precOnceDataSU,...
            fxSU,feSU,dSU,sSU);


% disp('DBG : runSpinupTEM : cPools # / cEco / s_c_cEco  ')
% if isfield(sSU.prev,'s_c_cEco')
% disp(num2str([1:size(sSU.c.cEco,2);sSU.c.cEco(1,:);sSU.prev.s_c_cEco(1,:)]))
% else
% disp('DBG : runSpinupTEM : cPools # / cEco  ')
% disp(num2str([1:size(sSU.c.cEco,2);sSU.c.cEco(1,:);NaN.*sSU.c.cEco(1,:)]))
% end
%% ------------------------------------------------------------------------
% 4 - create TEM structures for the transient run
% -------------------------------------------------------------------------
if runFlags.createStruct 
    disp([pad('INPUT ARGS',20) ' : ' pad('runTEM',20) ' | required SINDBAD structures are not provided as input. Reading/creating'])
    [fe,fx,s,d,info]	= createTEMStruct(info); %sujan
    if info.tem.model.flags.runOpti
        disp([pad('OPTI WARN',20) ' : ' pad('runTEM',20) ':'])
        disp(['                          >> Optimization Mode with runOpti = ' num2str(info.tem.model.flags.runOpti)])
        disp('                          >> runTEM called with empty SINDBAD structures and arrays')
        disp('                          >> Structures created in every iteration of OPTI')
        disp('                          >> INEFFICIENT IF THIS MESSAGE APPEARS MORE THAN ONCE')
    end
end
% and feed the end states of spinup to the initial condition of the forward
% model run
if ~isempty(sSU)        , s         = sSU;      end
if isempty(dSU)         , dSU       = d;        end
if isfield(dSU,'prev')  , d.prev	= dSU.prev;	end
%% ------------------------------------------------------------------------
% 5.0 - RUN THE MODEL
% -------------------------------------------------------------------------
for iStep = 1%:info.tem.model.time.nStepsDay %sujan need to handle this
    % this is where we can change the way to run the model, like, loading
    % data for every year (useful for large runs)
    % ---------------------------------------------------------------------
    % 5.1 - PRECOMPUTATIONS (ONCE)
    % ---------------------------------------------------------------------
    % -------------------------------------------------------------------------
    % get the precOnce data structure
    % -------------------------------------------------------------------------
    if isempty(precOnceData)
        [f,fe,fx,s,d,p] = runCoreTEM(f,fe,fx,s,d,p,info,true,false,false);
%         precOnceData	= struct;
%         for v = {'f','fe','fx','s','d','p'}
%             eval(['precOnceData.(v{1})	= ' v{1} ';']);
%         end
%     else
%         for v = {'f','fe','fx','s','d','p'}
%             eval([v{1} ' = precOnceData.(v{1});']);
%         end
    end
    [precOnceData,f,fe,fx,s,d,p] = setPrecOnceData(precOnceData,f,fe,fx,s,d,p,info,'runTEM');
    % the previous steps should come from the spinup
    if iStep == 1 
        if isfield(dSU,'prev')
            d.prev	= dSU.prev;
        end
    end %isfield added by sujan
    % ---------------------------------------------------------------------
    % 5.2 - CARBON AND WATER DYNAMICS IN THE ECOSYSTEM: FLUXES AND STATES
    % ---------------------------------------------------------------------
    [f,fe,fx,s,d,p]   = runCoreTEM(f,fe,fx,s,d,p,info,false,true,false);
    % ---------------------------------------------------------------------
    % ?.? - DO WE AGGREGATE STATES AND CHECK BALANCES HERE AND WRITE OUTPUT
    % ---------------------------------------------------------------------
end

% disp(['    TIM : runTEM : end : time : ' sec2som(toc(tstart))])
disp([pad('TOTAL TIMERUN',20) ' : ' pad('runTEM',20) ' | Total Time Needed: ' sec2som(toc(tstart))])
disp(' ')


end