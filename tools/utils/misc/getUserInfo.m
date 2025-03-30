function [userName, machineName]   =    getUserInfo()

if ismac
    
    userName        =   getenv('USER');
    machineName     =   getenv('HOSTNAME');
    
elseif isunix
    
    userName        =   getenv('USER');
    machineName     =   getenv('HOST');

else
    
    userName        =   getenv('username');
    machineName     =   getenv('computername');

end
end
