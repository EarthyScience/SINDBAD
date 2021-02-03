function [Alpha,Beta,kSat,thetaSat,psiSat,kFC,thetaFC,psiFC,kWP,thetaWP,psiWP] = calcSoilParamsSaxton2006(s,p,info,sl)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the soil hydraulic properties based on Saxton 2006
%
% Inputs:
%	- info  
%	- s.wd.p_soilTexture_[CLAY/SAND]: in fraction 
%   - p.pSoil.: texture-based parameters
%   - sl: soil layer to calculate property for
%
% Outputs:
%   - properties of moisture-retention curves: (Alpha and Beta)
%   - hydraulic conductivity (k), matric potention (psi) and porosity
%   (theta) at saturation (Sat), field capacity (FC), and wilting point
%   (WP)
%
% Modifies:
% 	- None
%
% References:
%  - Saxton, K. E., & Rawls, W. J. (2006). Soil water characteristic estimates by 
%       texture and organic matter for hydrologic solutions. 
%       Soil science society of America Journal, 70(5), 1569-1578.
% 
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala):
%
% Notes:
%   - PAW: Plant Avail. moisture (33-1500 kPa, matric soil), %v
%   - PAWB: Plant Avail. moisture (33-1500 kPa, bulk soil), %v
%   - SAT: Saturation moisture (0 kPa), %v
%   - WP: Wilting point moisture (1500 kPa), %v
%   - FC: Field Capacity moisture (33 kPa), %v
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> Get sand, clay, and organic matter contents
% CLAY: Clay, %w
% SAND: Sand, %w
% ORGM: Organic Matter, %w
% CLAY            =   p.soilTexture.CLAY .* info.tem.helpers.arrays.onespix ./ 100;
% SAND            =   p.soilTexture.SAND .* info.tem.helpers.arrays.onespix ./ 100;
% ORGM            =   p.soilTexture.ORGM .* info.tem.helpers.arrays.onespix ./ 100;

% s.wd.p_soilTexture_CLAY


CLAY            =   s.wd.p_soilTexture_CLAY(:,sl);
SAND            =   s.wd.p_soilTexture_SAND(:,sl);
ORGM            =   s.wd.p_soilTexture_ORGM(:,sl);

% CLAY            =   p.soilTexture.CLAY;
% SAND            =   p.soilTexture.SAND;
% ORGM            =   p.soilTexture.ORGM;

%% Moisture regressions

%--> Theta_1500t: 1500 kPa moisture, first solution, %v
%--> Theta_1500: 1500 kPa moisture, %v
Theta_1500t     =   -0.024   .* SAND + 0.487 .* CLAY + 0.006 .* ORGM ...
                    + 0.005  .* (SAND .* ORGM) - 0.013 .* (CLAY .* ORGM) ...
                    + 0.068  .* (SAND .* CLAY) + 0.031;
                
Theta_1500      =   Theta_1500t + (0.14 .* Theta_1500t - 0.02);

%--> Theta_33t: 33 kPa moisture, first solution, %v
%--> Theta_33: 33 kPa moisture, normal density, %v
Theta_33t       =   -0.251  .* SAND + 0.195 .* CLAY + 0.011 .* ORGM ...
                    + 0.006 .* (SAND .* ORGM) - 0.027 .* (CLAY .* ORGM) ...
                    + 0.452 .* (SAND .* CLAY) + 0.299;
                
Theta_33        =   Theta_33t + (1.283 .* (Theta_33t) .^ 2 - 0.374 .* Theta_33t - 0.015);

%--> Theta_s_33t: SAT-33 kPa moisture, first solution, %v
%--> Theta_s_33: SAT-33 kPa moisture, normal density %v
Theta_s_33t     =   0.278   .* SAND + 0.034 .* CLAY + 0.022 .* ORGM ...
                    - 0.018 .* (SAND .* ORGM) - 0.027 .* (CLAY .* ORGM) ...
                    - 0.584 .* (SAND .* CLAY) + 0.078;
                
Theta_s_33      =   Theta_s_33t + (0.636 .* Theta_s_33t - 0.107);
                    

%--> psi_et: Tension at air entry, first solution, kPa
%--> psi_e: Tension at air entry (bubbling pressure), kPa
Psi_et          =   abs(-21.67  .* SAND - 27.93 .* CLAY - 81.97 .* Theta_s_33 ...
                    + 71.12 .* (SAND .* Theta_s_33) + 8.29 .* (CLAY .* Theta_s_33) ... 
                    - 14.05 .* (SAND .* CLAY) + 27.16);
                
Psi_e           =   abs(Psi_et + (0.02 .* (Psi_et .^ 2) - 0.113 .* Psi_et - 0.70));
                    
%--> Theta_s: Saturated moisture (0 kPa), normal density, %v
%--> rho_N: Normal density, g cm-3
Theta_s         =   Theta_33 + Theta_s_33 - 0.097 .* SAND + 0.043;
rho_N           =  (1 - Theta_s) .* 2.65;

%% Density effects
%--> rho_DF: Adjusted density, g cm-3
%--> Theta_s_DF: Saturated moisture (0 kPa), adjusted density, %v
%--> Theta_33_DF: 33 kPa moisture, adjusted density, %v
%--> Theta_s_33_DF: SAT-33 kPa moisture, adjusted density, %v
%--> DF: Density adjustment Factor (0.9-1.3)

rho_DF          =   rho_N .* p.pSoil.DF;
% Theta_s_DF      =   1 - (rho_DF ./ 2.65); % original but does not include Theta_s
Theta_s_DF      =   Theta_s .* (1 - (rho_DF ./ 2.65)); % may be includes Theta_s
Theta_33_DF     =   Theta_33 - 0.2 .* (Theta_s - Theta_s_DF);
Theta_1500_DF   =   Theta_1500 - 0.2 .* (Theta_s - Theta_s_DF);
Theta_s_33_DF   =   Theta_s_DF - Theta_33_DF;

%% Moisture-Tension
%--> A,B: Coefficients of moisture-tension, Eq. [11]
%--> psi_Theta: Tension at moisture Theta, kPa

B               =   (log(1500) - log(33)) ./ (log(Theta_33) - log(Theta_1500));
A               =   exp(log(33) + B .* log(Theta_33));
% Psi_Theta       =   A .* ((Theta) .^ (-B));
% Psi_33          =   33.0 - ((Theta - Theta_33) .* (33.0 - Psi_e)) ./ (Theta_s - Theta_33);

%% Moisture-Conductivity
%--> lambda: Slope of logarithmic tension-moisture curve
%--> Ks: Saturated conductivity (matric soil), mm h-1
%--> K_Theta: Unsaturated conductivity at moisture Theta, mm h-1

lambda          =   1 ./ B;
Ks              =   1930 .* ((Theta_s - Theta_33) .^ (3 - lambda)) .* 24;

% K_Theta         =   Ks .* ((Theta ./ Theta_s) .^ (3 + (2 ./ lambda)));

%% Gravel Effects
%--> rho_B: Bulk soil density (matric plus gravel), g cm-3
%--> alphaRho: Matric soil density/gravel density (2.65) = rho/2.65
%--> Rv: Volume fraction of gravel (decimal), g cm -3
%--> Rw: Weight fraction of gravel (decimal), g g-1 
%--> Kb: Saturated conductivity (bulk soil), mm h-1

alphaRho        =   p.pSoil.matricSoilDensity ./ p.pSoil.gravelDensity;
Rv              =   (alphaRho .* p.pSoil.Rw) ./ (1 - p.pSoil.Rw .* (1 - alphaRho));
rho_B           =   rho_N .* (1 - Rv) + Rv .* 2.65;
% PAW_B           =   PAW .* (1 - p.soilTexture.Rv);
Kb              =   Ks .* ((1 - p.pSoil.Rw) ./ (1 - p.pSoil.Rw .* (1 - (3 .* alphaRho ./ 2))));

%% Salinity Effects
%--> phi_o: Osmotic potential at Theta = Theta_s, kPa
%--> phi_o_theta: Osmotic potential at Theta < Theta_s, kPa
%--> EC: Electrical conductance of a saturated soil extract, dS m-1 (dS/m = mili-mho cm-1)

phi_o           =   36 .* p.pSoil.EC;
% phi_o_theta     =   (Theta_s ./ Theta) .* 36 ./ p.soilTexture.EC;

%% Assign the variables for returning
Alpha           =   A;
Beta            =   B;
% thetaSat        =   Theta_s_DF;
thetaSat        =   Theta_s;
kSat            =   Kb;
psiSat          =   0 .* info.tem.helpers.arrays.onespix;
% thetaFC         =   Theta_33_DF;
thetaFC         =   Theta_33;
kFC             =   kSat .* ((thetaFC ./ thetaSat) .^ (3 + (2 ./ lambda)));
psiFC           =   33 .* info.tem.helpers.arrays.onespix;
% thetaWP         =   Theta_1500_DF;
thetaWP         =   Theta_1500;
psiWP           =   1500 .* info.tem.helpers.arrays.onespix;
kWP             =   kSat .* ((thetaWP ./ thetaSat) .^ (3 + (2 ./ lambda)));
end
