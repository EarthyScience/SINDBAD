function [f,fe,fx,s,d,p] = dyna_storeStates_simple(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% stores the time series of state variables at the end of every time step
%
% Inputs:
%	- tix  
%	- info
%   - variables in s.
%   - variables to store are taken from output.json (to.store, and to.write)
%       - only those in the selected model structure will be selected by setupCode.m   
%
% Outputs:
%   - d.storedStates: 
%
% Modifies:
% 	- None
%
% References:
%	- 
%
% Created by:
%   - Martin Jung (mjung)
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.01.2018 (mjung): automatic handling using setupCode
%   - 1.1 on 11.11.2019 (skoirala): creation of d.storedStates when tix==1
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
cvars_source        =   info.tem.model.code.variables.to.storeStatesSource;
cvars_destination	=   info.tem.model.code.variables.to.storeStatesDestination;
%%
%--> store the arrays in d.storedStates
for ii  =   1:length(cvars_source)
    sstr                    =   [char(cvars_destination{ii}) ' = ' char(cvars_source(ii)) ';'];
    eval(sstr);
end
end

