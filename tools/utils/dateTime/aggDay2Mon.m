function [Out,NaNCnt] = aggDay2Mon(In,startDate,endDate,days)

% Calculates monthly nanmean
    % In as 2D matrix (pixel, time) with daily data
    % startDate and endDate as string: 'MM-DD-YYYY'
    % Out as 2D matrix (pixel, time) with monthly data
    % NaNCnt as 2D matrix (pixel, time) with number of NaNs in the
    % corresponding month

startD = datenum(startDate);
endD = datenum(endDate);

xData = linspace(startD,endD,days);
[Y,M,D] = datevec(xData);

startYear = min(Y);
endYear = max(Y);

pix = size(In,1);
months = length(unique(Y))*12;

Out = NaN(pix,months);
NaNCnt = NaN(pix,months);

cnt = 1;
for year=startYear:endYear
    
    for month=1:12
        valid = Y==year & M==month;
        Out(:,cnt) = nanmean(In(:,valid),2);
        %NaNCnt(:,cnt) = sum(isnan(In(:,valid),2));
        cnt = cnt+1;
    end
    
end


end

