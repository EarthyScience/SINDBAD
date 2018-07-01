function [ f ] = readExpStruct(info)
%% (prelimenary) function that reads forcing from an ExpStruct used in the TWS paper
% contact: Tina Trautmann

% load the data
% for each variable, yet right now the DataPath for all is the same
tmpVar        = info.tem.forcing.VariableNames{1};
DataPath      = info.tem.forcing.(tmpVar).DataPath;
ExpStruct     = importdata(DataPath, 'ExpStruct');

% extract the needed forcing variables & adjust them
f             = ExpStruct.Forcing;

[xDay ]                   = CreateDateVector(ExpStruct.time); 
f.Year                    = year(xDay);
%dummy
% s.cd.LAI                     = ones(size(f.Tair)).*3;
%% ncarval reducing the size of forcing for faster tests
% for fn = fieldnames(f)'
%     f.(fn{:})   = f.(fn{:})(1:100:end,:);
% end

end


%% CreateDateVector - may be removed as seperate function to tools folder
function [xDay, xMonth, days, months, years] = CreateDateVector( time )
% creates date vectors for start and end dates
% [xDays xMonths days months years] = CreateDateVector( time )
% subsequently datevectors [Y,M,D] can be produced by datevec(xDay) resp. datevec(xMonth) 
% -------------
% considers Matlab version
% check for Leap years in data?

startDate   = time(1);
endDate     = time(2);
startD      = datenum(startDate,'mm-dd-yyyy');
endD        = datenum(endDate,'mm-dd-yyyy');
days        = endD-startD+1; % days between startD & endD + 1 to account start day
daysvec     = datevec(days-1); % duration of days as datevector
years       = daysvec(1)+1; % years of duration + 1 to account start year 
months      = daysvec(1)*12+daysvec(2); 

if verLessThan('matlab','8.4') % 8.4 is R2014b -> needed for datetime function
    xDay        = linspace(startD,endD,days);
    [Yd,Md,Dd]  = datevec(xDay)
    xMonth      = linspace(startD,endD,months);
    [Ym,Mm,Dm]  = datevec(xMonth); % haut f?r 2003-2010 genau hin - ausgenommen erster Februar (weil da noch D = 31.01.)
    Mm(2)       = 2; %adjust date-vector
    disp('Matlab version older than 8.4 - datetime does not work. Pay attention to Date-Vectors, they are only adjusted for 01-01-2003 to 12-31-2010!')
else
    xDay        = [datetime(startDate,'InputFormat','MM-dd-yyyy'),...
                    datetime(startDate, 'InputFormat','MM-dd-yyyy')+caldays(1:days-1)];
    [Yd,Md,Dd]  = datevec(xDay);
    xMonth      = [datetime(startDate,'InputFormat','MM-dd-yyyy'),...
                    datetime(startDate, 'InputFormat','MM-dd-yyyy')+calmonths(1:months-1)];
    [Ym,Mm,Dm]  = datevec(xMonth);
end


end
