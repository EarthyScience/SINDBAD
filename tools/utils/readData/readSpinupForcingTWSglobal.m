function [ fSU, infoSU] = readSpinupForcingTWSglobal(info)
% reads the global spin up forcing data similar to the TWS Paper (Trautmann et al.
% 2018, HESS)
%
% Usages: 
%   [fSU, infoSU] = readSpinupForcingTWS(info); 
% 
% Requires:              
%   - the info
% 
% Purposes: 
%   - reads the spin up forcing data used in the TWS paper
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

% DataPath = ['data/input/globalTWS/globalTWS_ForcingSpinUp.mat'];
% DataPath = convertToFullPaths(info, DataPath);

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

