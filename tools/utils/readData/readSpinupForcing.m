function [ fSU, infoSU] = readSpinupForcing(info)
% reads the spin up forcing data assuming that it's in the same data path as the forcing data 
%
% Usages: 
%   [fSU, infoSU] = readSpinupForcingTWS(info); 
% 
% Requires:              
%   - the info
% 
% Purposes: 
%   - applies readForcing with a predefined DataPath
%   - 
% 
% Conventions: 
%   - it has been made sure before, that all spin up forcing variables are
%   the same as the forcing variables
%   - 
% 
% Created by: 
%   - Tina Trautmann (ttraut@bgc-jena.mpg.de) 
% 
% References: 
%    
% 
% Versions: 
%   - 1.0 on 19.07.2018 

%% Path of the TWS Paper spin up

% OR assuming that the spin up data is in the same folder as the forcing
[pathstr, filename, exten] = fileparts(info.tem.forcing.oneDataPath);
filenameparts = strsplit(filename, '_');
DataPath = [pathstr '/' filenameparts{1} '_ForcingSpinUp' exten];

% Advantage: would have the fullpath
% Problem: oneDataPath could be empty..would have to loop over variables
%[pathstr,fname,ext] = fileparts(info.tem.forcing.oneDataPath)

% put the DataPath in the infoSU
infoSU = info;
infoSU.tem.forcing.oneDataPath = DataPath;


% read the forcing
fSU = readForcing(infoSU);



end

