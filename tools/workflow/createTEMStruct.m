function [fe,fx,s,d,info]     =  createTEMStruct(info)
% Creates the SINDBAD structures 
%
% Requires: 
%   + info and existence of all sindbad objects
%
% Purposes: 
%   Creates the fields of info.tem.helpers. for empty arrays that can be 
%   accessed by any function.
%
% Conventions: 
%   + (nTix)tix: (size) dimension in time
%   + (nPix)pix: (size) dimension in space
%   + (nZix)zix: (size) dimension for layers in vertical direction
%   + Always use these helpers in the spatialization of scalar values of
%     parameters in the approaches.
%
% Created by: 
%   Sujan Koirala (skoirala)
% 
% References: 
%   + 
%
% Versions: 
%   + 1.0 on 17.04.2018

%%

[info]                       =   createTEMHelper(info);
[s,d,info]                   =   createStateArray(info);                % create the arrays for state variables
[fe,fx,d,info]               =   createVariableArray(d,info);           % create the arrays for variables in f,fe,fx,d

end
