function x2 = getForcingMSC(x,years,info)
% prepares the forcing data for spinup using mean seasonal cycle
%
% Requires:
%   - original forcing
%   - years the size of the forcing through data in YYYY format
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
%   - Nuno Carvalhais (ncarval@bgc-jena.mpg.de)?
%
% References:
%
% Versions:
%   - 1.0 on 01.04.2018

%%
x2      = zeros(info.tem.helpers.sizes.nPix,floor(info.tem.model.time.nStepsYear));
den     = x2;
yearvec	= mkHvec(unique(years));
for i = yearvec
    tmp = x(:,years == i);
    if isleapyear(i)
        tmp(:,29+31)  = [];
    end
    den                 = den + double(isnan(tmp)==0);
    tmp(isnan(tmp)==1)  = 0;
    x2                  = x2+tmp;
end
x2	= x2 ./ den;
end 