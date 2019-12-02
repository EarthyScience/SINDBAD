function [f,fe,fx,s,d,p] = sumVariables_simple(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sums variables based on the list in modelRun.json
%
% Inputs:
%	- info
%   - variables to sum
%       - are taken from modelRun.json (varsToSum) with exhaustive list of
%       components
%       - this list is stored in info.tem.model.variables.to.sum in
%       readConfiguration
%       - only those in the selected model structure are selected by setupCode.m   
%
% Outputs:
%   - according to input in varsToSum
%   - e.g., fx.Q for total runoff, and fx.Et for evapotranspiration
%
% Modifies:
% 	- None
%
% References:
%	- 
%
% Created by:
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 11.11.2019
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> get the list of list of lines generated to sum the variables based on
%the input and model structure
CL                  =   info.tem.model.code.variables.to.sum.codeLines;
for ii  =	1:length(CL)
    sstr            =   char(CL(ii));
    eval(sstr);
end
end

