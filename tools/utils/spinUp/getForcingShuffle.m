function x2 = getForcingShuffle(x,info)
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
%   - Nuno Carvalhais (ncarval)?
%   - Sujan Koirala (skoirala)
% References:
%
% Versions:
%   - 1.0 on 01.04.2018

%%
years = f.Year;
yearUniq    = unique(years);

yearShuf = yearUniq(randperm(length(yearUniq)));



fns     = fieldnames(x);
for jj  = 1:numel(fns)
    if strcmpi(fns{jj},'Year'),continue,end
    
    xVar      = zeros(size());
    tmp             =    f.(fns{jj});
    tmp             =    getForcingShuffle(tmp,f.Year,info);
    x2.(fns{jj})    =    tmp;
    YearSize        =   size(tmp);
end
fSpin.Year          = ones(YearSize,info.tem.model.rules.arrayPrecision) .* 1901;


den     = x2;
for i = yearvec
    tmp = x(:,years == i);
    if isleapyear(i)
        tmp(:,29+31)  = [];
    end
    den                 = den + double(isnan(tmp)==0);
    tmp(isnan(tmp)==1)  = 0;
    x2                  = x2+tmp;
end
x2    = x2 ./ den;
end
