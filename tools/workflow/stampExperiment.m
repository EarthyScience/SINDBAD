function info   =	stampExperiment(info)

[info.experiment.usedVersion,~]     =   system('git rev-parse HEAD');
if ismac
    
    info.experiment.userName        =   getenv('USER');
    info.experiment.machine         =   getenv('HOSTNAME');
    
elseif isunix
    
    info.experiment.userName        =   getenv('USER');
    info.experiment.machine         =   getenv('HOST');

else
    
    info.experiment.userName        =   getenv('username');
    info.experiment.machine         =   getenv('computername');

end
tmpStrDate                          =   datestr(now,30);

info.experiment.runDate             =   tmpStrDate(1:end-7);

% info.experiment.sindbadroot         =   sindbadroot;
end