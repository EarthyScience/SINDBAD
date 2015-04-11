function [fx,s,d] = SoilMoistEffectRH_CASA(f,fe,fx,s,d,p,info,i)
% #########################################################################
% FUNCTION	: SoilMoistEffectRH_CASA
% 
% PURPOSE	: effect of soil moisture on soil decomposition as modelled in
%           CASA (BGME - below grounf moisture effect). The below ground
%           moisture effect, taken directly from the century model, uses
%           soil moisture from the previous month to determine a scalar
%           that is then used to determine the moisture effect on below
%           ground carbon fluxes. BGME is dependent on PET, Rainfall. This
%           approach is designed to work for Rainfall and PET values at the
%           monthly time step and it is necessary to scale it to meet that
%           criterion.
% 
% REFERENCES:
% Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
% Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
% production: A process model based on global satellite and surface data. 
% Global Biogeochemical Cycles. 7: 811-841. 
% 
% CONTACT	: Nuno
% 
% INPUT
% stepsPerYear  : number of time steps per year
%               (info.timeScale.stepsPerYear)
% PET           : potential evapotranspiration (mm)
%               (fi.PET)
% Rainfall      : rainfall (mm)
%               (fi.Rainfall)
% pwSM          : soil moisture sum of all layers of previous time step [mm] 
%               (d.Temp.pwSM)
% Aws           : curve (expansion/contraction) controlling parameter
%               (p.SoilMoistEffectRH.Aws)
% pBGME         : BGME of previous timestep
% 
% OUTPUT
% BGME          : below ground moisture effect on decomposition processes
%               ([])
% pBGME         : BGME of this time step (to be used in the next
%               calculation ([])
% 
% NOTES: the BGME is used as a scalar dependent on soil moisture, as the
% sum of soil moisture for all layers. This can be partitioned into
% different soil layers in the soil and affect independently the
% decomposition processes of pools that are at the surface and deeper in
% the soils.   
% 
% #########################################################################

% NUMBER OF TIME STEPS PER YEAR -> TIME STEPS PER MONTH
TSPY	= info.timeScale.stepsPerYear;
TSPM	= TSPY ./ 12;

% BELOW GROUND RATIO (BGRATIO) AND BELOW GROUND MOISTURE EFFECT (BGME)
BGRATIO = zeros(info.forcing.size(1),1);
BGME	= zeros(info.forcing.size(1),1);

% PREVIOUS TIME STEP VALUES
pBGME	= d.SoilMoistEffectRH.pBGME;

% FOR PET > 0
ndx = (f.PET(:,i) > 0);

% COMPUTE BGRATIO
BGRATIO(ndx)	= (d.Temp.pwSM(ndx,1) ./ TSPM  + f.Rain(ndx,i)) ./ f.PET(ndx,i);

% ADJUST ACCORDING TO Aws
BGRATIO         = BGRATIO .* p.SoilMoistEffectRH.Aws;

% COMPUTE BGME
ndx1        = ndx & (BGRATIO >= 0 & BGRATIO < 1);
BGME(ndx1)  = 0.1 + (0.9 .* BGRATIO(ndx1));
ndx2        = ndx & (BGRATIO >= 1 & BGRATIO <= 2);
BGME(ndx2)  = 1;
ndx3        = ndx & (BGRATIO > 2 & BGRATIO <= 30);
BGME(ndx3)  = 1 + 1 / 28 - 0.5 / 28 .* BGRATIO(ndx(ndx3));
ndx4        = ndx & (BGRATIO > 30);
BGME(ndx4)	= 0.5;

% WHEN PET IS 0, SET THE BGME TO THE PREVIOUS TIME STEP'S VALUE
ndxn        = (f.PET(:,i) <= 0);
BGME(ndxn)	= pBGME(ndxn);

BGME        = max(min(BGME,1),0);

% FEED IT TO THE STRUCTURE
d.SoilMoistEffectRH.BGME(:,i)	= BGME;
d.SoilMoistEffectRH.pBGME       = BGME;

end % function
