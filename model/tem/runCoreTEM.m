function [f,fe,fx,s,d,p] = runCoreTEM(f,fe,fx,s,d,p,info,doPrecOnce,doCore,doSpinUp)
% runs the coreTEM of SINDBAD depending on different mode and flags for
% runGenCode
%
% Requires:
%	- SINDBAD structures (f,fe,fx,s,d,p,info)
%   - flags for running coreTEM 
%       - doPrecOnce : true to do precOnce
%       - doCore : true to run time loop of core
%       - doSpinUp : true to spinup the model
%
% Purposes:
%   - returns f,fe,fx,s,d,p after running the coreTEM if doCore and
%   doSpinup are true
%   - returns the precOnce fields if only doPrecOnce is true
%   
%
% Conventions:
%  - selects the original handle or generated code based on info.tem.model.flags.runGenCode
%       - if true, 
%           - runs generated code for both coreTEM and preconce and core 
%       - if false, 
%           - runs original original handle of coreTEM and runPrecOnceTEM for forward run
%           - runs reduced versions, coreTEM4Spinup and runPrecOnceTEM4Spinup, for spinup (subset of
%           modules selected through use4spinup flag in
%           modelStructure.json
%       
% Created by:
%   - Nuno Carvalhais (ncarval@bgc-jena.mpg.de)
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% References:
%
% Versions:
%   - 1.1 on 10.07.2018 : includes functionalities of use4spinup
%   - 1.0 on 01.05.2018

%%
tstart = tic;
%% ------------------------------------------------------------------------
% get the handles for core and precOnce
% -------------------------------------------------------------------------
%--> check if the coreTEM is to be run in spinup mode or forward run

if doSpinUp
    fn{1}   =   'spinup';
%     doCore  =   1;
else
    fn{1}   =   'model';
end
%--> check if the generated code of the raw code is to be run
if info.tem.model.flags.runGenCode	
    fn{2}	=   'genMS';
else
    fn{2}	=   'rawMS';
end
%--> get the appropriate function handles of precomputation and coreTEM from the above two options

%--> run the handles
if doPrecOnce 
    hPrec               =   info.tem.(fn{1}).code.(fn{2}).precOnce.funHandle;
    [f,fe,fx,s,d,p]     =   hPrec(f,fe,fx,s,d,p,info); 
end
if doCore || doSpinUp
    hCore               =   info.tem.(fn{1}).code.(fn{2}).coreTEM.funHandle;
    [f,fe,fx,s,d,p]     =   hCore(f,fe,fx,s,d,p,info); 
end
% disp(['    TIME : runCoreTEM : end : inputs : ' num2str([doPrecOnce,doCore,doSpinUp],'%1.0f|') ' : time : ' sec2som(toc(tstart))])
% disp(f)
disp([pad('     EXEC FUNC',20,'left') ' : ' pad('runCoreTEM',20) ' | ' pad(['PrecOnce : ' func2str(info.tem.(fn{1}).code.(fn{2}).precOnce.funHandle)],40) ' | ' pad(['Core/Spinup : ' func2str(info.tem.(fn{1}).code.(fn{2}).coreTEM.funHandle)],40)])
disp([pad('     TIMERUN',20,'left') ' : ' pad('runCoreTEM',20) ' | ' pad(['doPrecOnce : ' num2str(doPrecOnce) ' , doCore : ' num2str(doCore) ' , doSpinUp : ' num2str(doSpinUp)],40,'both') ' | ' sec2som(toc(tstart))])


end