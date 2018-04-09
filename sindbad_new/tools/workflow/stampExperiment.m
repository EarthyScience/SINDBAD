function info = stampExperiment(info)

[info.experiment.usedVersion,~]	= system('git rev-parse HEAD');
info.experiment.userName        = getenv('username');
info.experiment.runDate         = datestr(now);
end