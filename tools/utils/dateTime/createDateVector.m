function [xOut, days, months, years, Y, M, D] = createDateVector(startDate, endDate, steps )
% creates date vectors for start and end dates
% subsequently datevectors [Y,M,D] can be produced by datevec(xOut) resp. datevec(xOut)
% -------------
% check for Leap years in data?
%
% Usages: 
%   - [xOut, days, months, years, Y, M, D] = createDateVector(startDate, endDate, steps ); 
% 
% Requires: 
%   - startDate: 'yyyy-mm-dd'
%   - endDate:   'yyyy-mm-dd'
%   - steps: 'd', 'm', 'y'
% 
% Purposes: 
%   - create date vectors  
% 
% Conventions: 
% 
% Created by: 
%   - Tina Trautmann (ttraut) 
% 
% References: 
%    
% 
% Versions: 
%   - 1.0 on 11.07.2018 
%

%%
tmp = strsplit(startDate,'-');
if str2double(tmp{1}) > str2double(tmp{3})
startD      = datenum(startDate,'yyyy-mm-dd');
endD        = datenum(endDate,'yyyy-mm-dd');
    inForm      = 'yyyy-MM-dd';
else
    startD      = datenum(startDate,'mm-dd-yyyy');
    endD        = datenum(endDate,'mm-dd-yyyy');
    inForm      = 'MM-dd-yyyy';
end
days        = endD-startD+1; % days between startD & endD + 1 to account start day
daysvec     = datevec(days-1); % duration of days as datevector
years       = daysvec(1)+1; % years of duration + 1 to account start year
months      = daysvec(1)*12+daysvec(2);

switch steps
    case 'd'
        xOut        = [datetime(startDate,'InputFormat',inForm),...
            datetime(startDate, 'InputFormat',inForm)+caldays(1:days-1)];
    case 'm'
        xOut      = [datetime(startDate,'InputFormat',inForm),...
            datetime(startDate, 'InputFormat',inForm)+calmonths(1:months-1)];
    case 'y'
        xOut      = [datetime(startDate,'InputFormat',inForm),...
            datetime(startDate, 'InputFormat',inForm)+calmonths(1:years-1)];
    otherwise
        disp(['WARN : readInput : not a valid time step : ' steps ]);
end

[Y,M,D]  = datevec(xOut);


end

