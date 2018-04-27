function x2 = prepSpinupYear(x,years,info)
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
end % function