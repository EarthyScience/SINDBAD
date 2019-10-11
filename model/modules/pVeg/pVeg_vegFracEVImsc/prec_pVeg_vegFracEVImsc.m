function [f,fe,fx,s,d,p] = prec_pVeg_vegFracEVImsc(f,fe,fx,s,d,p,info)

% #########################################################################
% PURPOSE	: sets p.vegFrac by reading the mean seasonal cycle of MODIS
% EVI
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% p.pVeg.vegFr  : scaling parameter
% EVI_MSC       : reads it from the forcing data path + 'MODIS_EVI_MSC.mat'
%                   (pix,12)
%
% OUTPUT
% p.pVeg.vegFr   : scaling parameter .* EVI_MSC in size(pix,tix)
% d.pVeg.EVI_MSC : EVI MSC (pix,tix)
%
% NOTES:
%
% #########################################################################

% empty daily array
d.pVeg.EVI_MSC = info.tem.helpers.arrays.nanpixtix;

% load the MSC
pth_in = fileparts(info.tem.forcing.oneDataPath);
load([pth_in '/MODIS_EVI_MSC.mat'], 'EVI_MSC');

EVI_MSC(isnan(EVI_MSC)) = 0;

% assign each month to the daily values
[~,M] =datevec(info.tem.helpers.dates.day);
for mm=1:12
    tmp = EVI_MSC(:,mm);
    tmp2 = tmp .* ones(size(d.pVeg.EVI_MSC(:,M==mm)));
    d.pVeg.EVI_MSC(:,M==mm) = tmp2;
end

% scale it with the p.pVeg.vegFr
p.pVeg.vegFr = min(p.pVeg.vegFr .*  d.pVeg.EVI_MSC, 1);


end
