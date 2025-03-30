function [ outVar ] = adjustPrecision( info, inVar ) 
% Usages: 
%   [outVar] = adjustPrecision(info, inVar); 
%   [f]      = adjustPrecision(info, f); 
%   [Tair]   = adjustPrecision(info, Tair); 
% 
% Requires: 
%   - inVar:    numeric variable(s) that precision should be changed  
%       - can be a structure with 2 levels 
%                
%   - the info: with the field info.tem.model.rules.arrayPrecision 
% 
% Purposes: 
%   - adjusts the precision as defined by info.tem.model.rules.arrayPrecision 
% 
% Conventions: 
% 
% Created by: 
%   - Tina Trautmann (ttraut) 
% 
% References: 
%    
% 
% Versions: 
%   - 1.0 on 27.06.2018 
 
arPrec    = info.tem.model.rules.arrayPrecision; 
 
 
if isstruct(inVar) 
    outVar = inVar; 
    for field = fieldnames(inVar)' 
        outVar.(field{1}) = funPrec(inVar.(field{1}),arPrec); 
    end 
     
else 
    outVar  = funPrec(inVar,arPrec); 
end 
 
end 
 
function [newPrec] = funPrec(oldPrec, arPrec) 
    if isnumeric(oldPrec) 
        newPrec = feval(arPrec, oldPrec);
    else 
        newPrec = oldPrec; 
    end 
end 
