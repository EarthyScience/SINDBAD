function [Z_downsamp,t_downsamp] = temporalAggr(Z,t,varargin)
% downsample_ts function downsamples 1D or 3D data to monthly, yearly, hourly,
% minutely, or secondly data. This function was originally designed to
% create monthly mean time series from daily geospatial climate data. 
% 
%% Syntax 
% 
%  Z_downsamp = downsample_ts(Z,t)
%  Z_downsamp = downsample_ts(...,'DownsamplingPeriod')
%  Z_downsamp = downsample_ts(...,'function')
%  [Z_downsamp,t_downsamp] = downsample_ts(...)
% 
%% Description 
% 
% Z_downsamp = downsample_ts(Z,t) downsamples Z, which must be 
% provided with a corresponding time vector t.  Z can be 1D if its
% length matches the length of t.  If Z is three-dimensional, the 
% length of its third dimension must match the length of t. For geospatial 
% climate data arrays, dimensions of Z might correspond to pix x time or 
% lon x lat x time.  
%
% Z_downsamp = downsample_ts(...,'DownsamplingPeriod') specifies a
% downsampling period as 
% 
% * 'year' 
% * 'month' (default)  
% * 'day' 
% * 'hour' 
% * 'minute' 
% * 'second' 
% 
% Z_downsamp = downsample_ts(...,'function') specifies a function to
% perform on the data. By default, monthly averages are taken, but you may
% wish to return the monthly median or monthly standard deviation or any of
% the functions listed below.
% 
% A note on functions which ignore NaNs: To get the monthly means of data
% while ignoring NaN values, you can use the 'nanmean' option. The
% nanmean function is part of the Statistics Toolbox, but may also be
% found as part of the  NaN Suite on File Exchange. However, the File Exchange versions mix up the order
% of dimensions and flags for nanstd, nanvar, nanmin, and nanmax, so you will 
% need the Statistics Toolbox for those particular functions.  In all, the
% following functions are available: 
% 
%     * 'mean' (default) 
%     * 'nanmean' ignores NaN values in Z. Requires Statistics toolbox or NaN Suite. 
%     * 'median' 
%     * 'nanmedian' ignores NaN values in Z. Requires Statistics toolbox or NaN Suite. 
%     * 'min' 
%     * 'nanmin' ignores NaN values in Z. Requires Statistics toolbox. 
%     * 'max' 
%     * 'nanmax' ignores NaN values in Z. Requires Statistics toolbox. 
%     * 'std' standard deviation. 
%     * 'nanstd' ignores NaN values in Z. Requires Statistics toolbox. 
%     * 'var' variance. 
%     * 'nanvar' ignores NaN values in Z. Requires Statistics toolbox. 
%     * 'mode'  
%     * 'sum'
%     * 'nansum'
%
% [Z_downsamp,t_downsamp] = downsample_ts(...) also returns a time array
% corresponding to Z_downsamp. If Z is 3D or, t_downsamp corresponds
% to the third dimension of Z_downsamp. Each value in t_downsamp
% represents the mean time of all data contributing to that slice of
% Z_downsamp.  
% 
%% Example: Downsample daily data to monthly means: 
% 
% t = datenum(2000,1,1:3*365); % 3 yrs of daily data
% y = 10+5*sin(t*pi/365)+rand(size(t));
% plot(t,y) 
% datetick
% hold on; box off
% 
% [y_monthlymean,t_monthly] = downsample_ts(y,t); 
% plot(t_monthly,y_monthlymean,'ro-')
% 
%% Author Info
% This function was written by Chad A. Greene of the University 
% of Texas at Austin's Insititue for Geophysics (UTIG). Come see 
% Chad at http://www.chadagreene.com.  November 5, 2014. 
% Updated December 30, 2014 to include sum and nansum capability. 
% 
% See also mean, datenum, and accumarray. 
%% Input error checks: 
narginchk(2,4)
assert(isnumeric(Z)==1,'Input data2D must be numeric.')
assert(isvector(t)==1,'Input time array must be a 1D array.') 
assert(isvector(Z)==1|ndims(Z)==2,'Input data2D must be a 1D array or a 2D matrix.') 
Zdims = ndims(Z); 
assert(Zdims<3,'Z must be 1D or 2D.') 
if Zdims==2
    assert(size(Z,2)==length(t),'Length of t must match dimension 2 of input data matrix.')
else
    assert(length(Z)==length(t),'Length of t must match length of input data.') 
end
%% Input manipulation: 
% Convert (assumed) date strings to datenums if necessary: 
if ischar(t)
    t = datenum(t); 
end
% Transpose t to have a consistent starting point: 
t_is_row = false; 
if isrow(t) 
    t_is_row = true; 
    t = t'; 
end
%% Parse optional inputs: 
DownsamplingPeriod = 'monthly'; % default monthly averages
if any(strncmpi(varargin,'y',1)+strncmpi(varargin,'an',2))
    DownsamplingPeriod = 'yearly'; 
end
if any(strncmpi(varargin,'da',2))
    DownsamplingPeriod = 'daily'; 
end
if any(strncmpi(varargin,'h',1))
    DownsamplingPeriod = 'hourly'; 
end
if any(strncmpi(varargin,'minute',4))
    DownsamplingPeriod = 'minutely'; 
end
if any(strncmpi(varargin,'sec',3))
    DownsamplingPeriod = 'secondly'; 
end
method = 'mean'; % mean is default. 
if any(strcmpi(varargin,'nanmean'))
    method = 'nanmean'; 
end
if any(strncmpi(varargin,'med',3))
    method = 'median'; 
end
if any(strncmpi(varargin,'nanmed',6))
    method = 'nanmedian'; 
end
if any(strncmpi(varargin,'max',3))
    method = 'max'; 
end
if any(strcmpi(varargin,'nanmax'))
    assert(license('test','statistics_toolbox')==1,'nanmax requires statistics toolbox because the free version of nanmax that you will find on the internet does not behave exactly the same as the stats toolbox version.')
    method = 'nanmax'; 
end
if any(strncmpi(varargin,'min',3))
    method = 'min'; 
end
if any(strcmpi(varargin,'nanmin'))
    assert(license('test','statistics_toolbox')==1,'nanmin requires statistics toolbox because the free version of nanmin that you will find on the internet does not behave exactly the same as the stats toolbox version.')
    method = 'nanmin'; 
end
if any(strcmpi(varargin,'std'))
    method = 'std'; 
end
if any(strcmpi(varargin,'nanstd'))
    assert(license('test','statistics_toolbox')==1,'nanstd requires statistics toolbox because the free version of nanstd that you will find on the internet does not behave exactly the same as the stats toolbox version.')
    method = 'nanstd'; 
end
if any(strncmpi(varargin,'var',3))
    method = 'var'; 
end
if any(strcmpi(varargin,'nanvar'))
    assert(license('test','statistics_toolbox')==1,'nanvar requires statistics toolbox because the free version of nanvar that you will find on the internet does not behave exactly the same as the stats toolbox version.')
    method = 'nanvar'; 
end
if any(strcmpi(varargin,'mode'))
    method = 'mode'; 
end
if any(strcmpi(varargin,'sum'))
    method = 'sum'; 
end
if any(strcmpi(varargin,'nansum'))
    method = 'nansum'; 
end
%% Begin calculations: 
[y,mo,d,h,mi,s] = datevec(t); 
switch DownsamplingPeriod
    case 'yearly'
        if max(diff(t))>367,
            warning('Some time steps in input t are more than a year apart. This may cause strange results when taking yearly averages.'); 
        end
        CompArray = datenum(y,1,1); % array for comparison. Has unique values of ut and length of t.  
        
    case 'monthly'
        if max(diff(t))>60,
            warning('Some time steps in input t are more than a 60 days apart. This may cause strange results when taking monthly averages.'); 
        end
        CompArray = datenum(y,mo,1); 
        
    case 'daily'
        if max(diff(t))>2,
            warning('Some time steps in input t are more than a 2 days apart. This may cause strange results when taking daily averages.'); 
        end
        CompArray = datenum(y,mo,d); 
        
    case 'hourly'
        if max(diff(t))>1/12,
            warning('Some time steps in input t are more than a 2 hours apart. This may cause strange results when taking hourly averages.'); 
        end
        CompArray = datenum(y,mo,d,h,1,1); 
        
    case 'minutely'
        if max(diff(t))>1/(24*30),
            warning('Some time steps in input t are more than a 2 minutes apart. This may cause strange results when taking averages of every minute.'); 
        end
        CompArray = datenum(y,mo,d,h,mi,1); 
        
    case 'secondly'
        if max(diff(t))>1/(24*30*60),
            warning('Some time steps in input t are more than a 2 seconds apart. This may cause strange results when taking averages of every second.'); 
        end
        CompArray = datenum(y,mo,d,h,mi,s); 
end
ut = unique(CompArray); % array of unique downsamplin' times. 
%% Preallocate outputs: 
if Zdims==2
    Z_downsamp = NaN(size(Z,1),length(ut)); 
else
    Z_downsamp = NaN(1,length(ut)); 
end
    
if nargout==2
    if isrow(t)
        t_downsamp = NaN(1,length(ut)); 
    else
        t_downsamp = NaN(length(ut),1); 
    end
end
%% Compute means or otherwise for each unique output time: 
for k = 1:length(ut)
    switch method
        case 'mean'
            if Zdims==2
                Z_downsamp(:,k) = mean(Z(:,CompArray==ut(k)),2); 
            else
                Z_downsamp(k) = mean(Z(CompArray==ut(k))); 
            end
            
        case 'nanmean'
            if Zdims==2
                Z_downsamp(:,k) = nanmean(Z(:,CompArray==ut(k)),2); 
            else
                Z_downsamp(k) = nanmean(Z(CompArray==ut(k))); 
            end
            
        case 'median'
            if Zdims==2
                Z_downsamp(:,k) = median(Z(:,CompArray==ut(k)),2); 
            else
                Z_downsamp(k) = median(Z(CompArray==ut(k)));
            end
            
        case 'nanmedian'
            if Zdims==2
                Z_downsamp(:,k) = nanmedian(Z(:,CompArray==ut(k)),2); 
            else
                Z_downsamp(k) = nanmedian(Z(CompArray==ut(k))); 
            end
            
        case 'max' 
            if Zdims==2
                Z_downsamp(:,k) = max(Z(:,CompArray==ut(k)),[],2); 
            else
                Z_downsamp(k) = max(Z(CompArray==ut(k))); 
            end
            
        case 'nanmax' 
            if Zdims==2
                Z_downsamp(:,k) = nanmax(Z(:,CompArray==ut(k)),[],2); 
            else
                Z_downsamp(k) = nanmax(Z(CompArray==ut(k))); 
            end
            
        case 'min' 
            if Zdims==2
                Z_downsamp(:,k) = min(Z(:,CompArray==ut(k)),[],2);
            else
                Z_downsamp(k) = min(Z(CompArray==ut(k)));
            end
            
        case 'nanmin' 
            if Zdims==2
                Z_downsamp(:,k) = nanmin(Z(:,CompArray==ut(k)),[],2);
            else
                Z_downsamp(k) = nanmin(Z(CompArray==ut(k)));
            end
            
        case 'std' 
            if Zdims==2
                Z_downsamp(:,k) = std(Z(:,CompArray==ut(k)),0,2);
            else
                Z_downsamp(k) = std(Z(CompArray==ut(k)));
            end
            
        case 'nanstd' 
            if Zdims==2
                Z_downsamp(:,k) = nanstd(Z(:,CompArray==ut(k)),0,2);
            else
                Z_downsamp(k) = nanstd(Z(CompArray==ut(k)));
            end
            
        case 'var' 
            if Zdims==2
                Z_downsamp(:,k) = var(Z(:,CompArray==ut(k)),0,2);
            else
                Z_downsamp(k) = var(Z(CompArray==ut(k)));
            end
            
        case 'nanvar' 
            if Zdims==2
                Z_downsamp(:,k) = nanvar(Z(:,CompArray==ut(k)),0,2);
            else
                Z_downsamp(k) = nanvar(Z(CompArray==ut(k)));
            end
            
        case 'mode' 
            if Zdims==2
                Z_downsamp(:,k) = mode(Z(:,CompArray==ut(k)),2);
            else
                Z_downsamp(k) = mode(Z(CompArray==ut(k)));
            end
            
        case 'sum'
            if Zdims==2
                Z_downsamp(:,k) = sum(Z(:,CompArray==ut(k)),2);
            else
                Z_downsamp(k) = sum(Z(CompArray==ut(k)));
            end
            
        case 'nansum'
            if Zdims==2
                Z_downsamp(:,k) = nansum(Z(:,CompArray==ut(k)),2);
            else
                Z_downsamp(k) = nansum(Z(CompArray==ut(k)));
            end          
    end
    if nargout==2
        t_downsamp(k) = mean(t(CompArray==ut(k))); 
    end
end
%% Ensure direction of t_downsamp matches direction of t:  
if nargout==2 && t_is_row
    t_downsamp = t_downsamp'; 
end
end