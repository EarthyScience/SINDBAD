function x2 = getForcingMSC(x,years,info)
% prepares the forcing data for spinup using mean seasonal cycle
%
% Requires:
%   - original forcing 
%   - years: the size of the forcing through data in YYYY format
%      - for daily forcing for 10 years, the years will be size 3652 with
%       $YYYY replacing each date of that year
%   - info to access the helpers
%
% Purposes:
%   - to prepare the mean seasonal cycle forcing for spinup
%   
% Conventions:
%
% Created by:
%   - Nuno Carvalhais (ncarval)?
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.1 on 11.07.2018: added functionality to handle data that do not
%   start on the Jan 01 or end on dec 31 (skoirala).
%   - 1.0 on 01.04.2018

%%
x2      = zeros(info.tem.helpers.sizes.nPix,floor(info.tem.model.time.nStepsYear));
den     = x2;
yearOri = unique(years);
%% check if the some year in the data do not have a complete year of 365 or 366 days and disregard those data in MSC calculation
datSel  = [];
yearSel = [];
for yr = 1:numel(yearOri)
    countDays= sum(years == yearOri(yr));
    if countDays >= 365        
        datSel  = [datSel x(:,years == yearOri(yr))];
        yearSel  = [yearSel years(:,years == yearOri(yr))];
    end
end

yearvec    = mkHvec(unique(yearSel));
for i = yearvec
    tmp = datSel(:,yearSel == i);
    if isleapyear(i)
        tmp(:,29+31)  = [];
    end
    den                 = den + double(isnan(tmp)==0);
    tmp(isnan(tmp)==1)  = 0;
    x2                  = x2+tmp;
end
x2    = x2 ./ den;
end 