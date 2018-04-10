function info = stampExperiment(info)

[info.experiment.usedVersion,~]	= system('git rev-parse HEAD');
info.experiment.userName        = getenv('username');
info.experiment.machine         = getenv('computername');
info.experiment.runDate         = datestr(now);
info.experiment.sindbadroot		= sindbadroot;
end