function info   =	setExperimentInfo(info)

[info.experiment.usedVersion,~]     =   system('git rev-parse HEAD');

[userName, machineName]             =   getUserInfo();
info.experiment.userName            =   userName;
info.experiment.machine             =   machineName;

tmpStrDate                          =   datestr(now,30);

info.experiment.runDate             =   tmpStrDate(1:end-7);

% info.experiment.sindbadroot         =   sindbadroot;
end
