function x2 = mkSpinUpYear(x,years,info)

x2      = zeros(info.ForcingSize(1),floor(info.StepsPerYear));
yearvec	= mkHvec(years);

for i = yearvec
    tmp = x(:,years == i);
    if isleapyear(i)
        tmp(:,29+31)  = [];
    end
    x2 = x2 + tmp;
end
x2 = x2 ./ numel(yearvec);
end % function