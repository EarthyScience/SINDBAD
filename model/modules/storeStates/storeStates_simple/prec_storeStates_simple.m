function [f,fe,fx,s,d,p] = prec_storeStates_simple(f,fe,fx,s,d,p,info,tix)
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
%--> added by sujan on 09.11.2019 to create all the stored states arrays at
% the beginning of the model simulation at t=1 when all the s. variables
% are already available, and their sizes can be inferred
numTimeStr              =   num2str(info.tem.helpers.sizes.nTix);
for ij                  =	1:numel(cvars_source)
    var2ss              =   cvars_source{ij}(1:end-1);
    var2sdtmp           =   strsplit(cvars_destination{ij},'(');
    var2sd              =   var2sdtmp{1};
    evalStr             =   [var2sd ' = reshape(repelem(' var2ss ',1,' numTimeStr '),[size(' var2ss '),' numTimeStr ']);'];
    eval(evalStr)
end
% --> end of array creation
end

