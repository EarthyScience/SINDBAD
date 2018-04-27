function [ f ] = readExpStruct(info)
%% (prelimenary) function that reads forcing from an ExpStruct used in the TWS paper
% contact: Tina Trautmann

% load the data
% for each variable, yet right now the DataPath for all is the same
tmpVar        = info.tem.forcing.VariableNames{1};
DataPath      = info.tem.forcing.(tmpVar).DataPath;
ExpStruct     = importdata(DataPath, 'ExpStruct');

% extract the needed forcing variables & adjust them
f.Tair                    = ExpStruct.Forcing.T;            % daily temperature [?C]
f.TairDay                 = f.Tair;                         % daily temperature [?C]

f.Rain                    = ExpStruct.Forcing.P;            % daily rainfall mm/day
f.Snow                    = zeros(size(f.Rain));            % snow fall [mm/day]
ndx                       = f.Tair < 0;
f.Snow(ndx)               = f.Rain(ndx);
f.Rain(ndx)               = 0;

f.PsurfDay                = ones(size(f.Tair)) .* 100;      % atmospheric pressure during the daytime [kPa]
f.Rn                      = ExpStruct.Forcing.Rn;           % net radiation [MJ/m2/day]

f.Rn(f.Rn<1)              = 1;

f.PET                     = CalcPETPriestleyTaylor(f.Tair,f.Rn);        
f.PET(f.PET<0)            = 0;

[xDay ]                   = CreateDateVector(ExpStruct.time); 
f.Year                    = year(xDay);

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
    [Ym,Mm,Dm]  = datevec(xMonth); % haut for 2003-2010 genau hin - ausgenommen erster Februar (weil da noch D = 31.01.)
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

%% CalcPriestleyTaylor - may be removed as seperate function to tools folder
function [ PET ] = CalcPETPriestleyTaylor(Tair, Rn)
% Tair    = ExpStruct.Forcing.T; % [deg C]
% Rn      = ExpStruct.Forcing.Rn; % [MJ/m2/day]
% PET [mm/day]

e=0.611.*exp(17.27.*Tair./(Tair+237.3)); %saturation vapor pressure []
s=4098.*e./((Tair+237.3).^2); %slope vapor pressure curve [kPa/degC]
l=2.501 - (2.361 * 0.001).*Tair; %latent heat of vaporization [MJ /kg]
% Priestley and Taylor (1972)
p=0.00163*101.3./l; % psychometric constant [kPa C]
PET =  (s .* Rn)./(s + p); % ~ Penman-Monteith without aerodynamic component, assuming alpha = 1

PET=PET./l; 

end