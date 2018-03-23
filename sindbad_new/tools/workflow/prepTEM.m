function [info, f]   = prepTEM(info)
%% prepares the experiment and model run
% INPUT:    info
% OUTPUT:   info
%           f:      forcing structure 
%
% comment:  
%
% steps:
%   1) prepForcing
%   2) prepSpinup
%   3) prepParams
%   4) createArrays4Model
%   5) runPrec 

%% 1) prepare forcing data
% evaluate function handle in forcing
f = info.tem.forcing.fun.import;



end