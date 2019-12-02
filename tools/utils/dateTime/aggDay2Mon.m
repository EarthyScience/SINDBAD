function [Out,NaNCnt] = aggDay2Mon(In,startDate,endDate)
% Calculates monthly nanmean
%
% Usages:
%   [Out,NaNCnt] = aggDay2Mon(In,startDate,endDate)
%
% Requires:
%   - In: daily time series of a variable (pix,tix)
%   - startDate: start date of time series 'YYYY-MM-DD'
%   - endDate: end date of time series 'YYYY-MM-DD'
%   - Out: time series with monthly averages (pix,tix) excluding NaNs
%   - NaNCnt: count of NaNs in each month (pix,tix)
%
% Purposes:
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
%   - 2.0 on 12.07.2018

%% with info as input
% xdays        = length(info.tem.helpers.dates.day);
% xmonths      = length(info.tem.helpers.dates.month);
% xDay         = info.tem.helpers.dates.day;
% 
% pix = info.tem.helpers.sizes.nPix;

%% otherwise
% startD  = datenum(startDate);
% endD    = datenum(endDate);
% xData   = linspace(startD,endD,days);
% [Y,M,D] = datevec(xData);
% startYear = min(Y);
% endYear = max(Y);
% 
% pix = size(In,1);
% months = length(unique(Y))*12;
% Out     = NaN(pix,months);
% NaNCnt  = NaN(pix,months);
% 
% cnt = 1;
% for year=startYear:endYear
%     
%     for month=1:12
%         valid = Y==year & M==month;
%         Out(:,cnt) = nanmean(In(:,valid),2);
%         NaNCnt(:,cnt) = sum(isnan(In(:,valid),2));
%         cnt = cnt+1;
%     end
%     
% end



[xDay, xdays, xmonths,xyears, Y, M] = createDateVector(startDate,endDate,'d');

startYear   = min(Y);
endYear     = max(Y);


pix     = size(In,1);

Out     = NaN(pix,xmonths);
NaNCnt  = NaN(pix,xmonths);

cnt = 1;
for year=startYear:endYear
    
    for month=1:12
        % only average if there are valids
        valid = Y==year & M==month;
        if sum(valid(:)) ~= 0
            Out(:,cnt)      = nanmean(In(:,valid),2);
            NaNCnt(:,cnt)   = sum(isnan(In(:,valid)),2);
            cnt = cnt+1;
        end
    end
    
end


end

