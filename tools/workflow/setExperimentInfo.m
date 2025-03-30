function info   =    setExperimentInfo(info)
% sets user-based information of the experiement 
%
% Usages:
%   info   =    setExperimentInfo(info)
%
% Requires:
%   + the info
%
% Purposes:
%   + get the date of the run
%   + version of the gir repo
%   + username and machine 
%
% Conventions:
%   + generated date is in YYYYMMDD format
%
% Created by:
%   + Sujan Koirala (skoirala)
%
% References:
%   +
%
% Versions:
%   + 1.0 on 22.06.2018

%%
[info.experiment.usedVersion,~]     =   system('git rev-parse HEAD');

[userName, machineName]             =   getUserInfo();
info.experiment.userName            =   userName;
info.experiment.machine             =   machineName;

tmpStrDate                          =   datestr(now,30);

info.experiment.runDate             =   tmpStrDate(1:end-7);

% info.experiment.sindbadroot         =   sindbadroot;
end
