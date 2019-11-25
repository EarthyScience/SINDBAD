function [f,fe,fx,s,d,p] = prec_pVeg_vegFracEVIdailymsc(f,fe,fx,s,d,p,info)
% #########################################################################
% sets p.vegFrac by reading the daily mean seasonal cycle of MODIS
%
% Inputs:
%	- s.cd.vegFrac:     scaling parameter
%   - f.EVI_MSC:        reads it from the forcing data path + 'MODIS_EVI_MSC.mat'
%                       (pix,12)
%
% Outputs:
%   - s.cd.vegFrac   : scaling parameter .* EVI_MSC in size(pix,tix)
%
% Modifies:
% 	- 
%
% References:
%	- 
%
% Created by:
%   - Tina Trautmann (sets p.vegFrac by reading the daily mean seasonal cycle of MODIS@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% #########################################################################

%% READING f.EVI_MSC goes to another script!!!
% empty daily array
d.pVeg.EVI_MSC = info.tem.helpers.arrays.nanpixtix;

% load the daily MSC
pth_in = fileparts(info.tem.forcing.oneDataPath);
load([pth_in '/MODIS_EVI_MSC_smoothed.mat'], 'EVI_MSC_d');

EVI_MSC = EVI_MSC_d;
EVI_MSC(isnan(EVI_MSC)) = 0;

% assign each day to the daily values
[~,M,D] =datevec(info.tem.helpers.dates.day);

md = 1;
for mm=1:12
    d_month = eomday(1,mm);
    for dd=1:d_month
        tmp = EVI_MSC(:,md);
        tmp2 = tmp .* ones(size(d.pVeg.EVI_MSC(:,M==mm & D==dd)));
        d.pVeg.EVI_MSC(:,M==mm & D==dd) = tmp2;
        md = md +1;
    end
end

% assign 29th Feb the avg of 28th Feb + 1st Mar
tmp3 = (EVI_MSC(:,59) + EVI_MSC(:,60) ) ./ 2;
d.pVeg.EVI_MSC(:,M==2 & D==29)  = tmp3 .* ones(size(d.pVeg.EVI_MSC(:,M==2 & D==29)));

%% THE FOLLOWING REMAINS HERE
% scale daily MSC of EVI with the s.cd.vegFrac
s.cd.vegFrac = min(s.cd.vegFrac .*  f.EVI_MSC, 1);


end
