function soilm_parm = calc_soilm_prms(CLAY, SAND, SLDP, soilm_prm)
% #########################################################################
% CALCULATE SOIL MOISTURE PARAMETERS
% soilm_prm = calc_soilm_prms(CLAY, SAND, soilm_prm)
% 
% soilm_parm    : soil moisture parameter output array
% CLAY          : clay array
% SAND          : sand array
% soilm_prm     : soil moisture parameter to calculte:
%               : wilting point     : 'wpt'
%               : field capacity    : 'fc'
%               : alpha             : 'alpha'
%               : beta              : 'beta'
% 
% Reference:
% Saxton, K.E., W.J. Rawls, J.S. Romberger, and R.I. Papendick. 1986. 
% Estimating generalized soil-water characteristics from texture. 
% Soil Sci. Soc. Am. J. Vol. 50(4):1031-1036.
% http://www.bsyse.wsu.edu/saxton/soilwater/Article.htm
% #########################################################################

% SOIL DEPTH
SD  = SLDP;

% CONVERT SAND AND CLAY TO PERCENTAGES
CLAY    = CLAY .* 100;
SAND    = SAND .* 100;

soilm_prm = lower(soilm_prm);
% ASSIGN VARIABLES FOR CALCULATIONS
switch soilm_prm
    case 'wpt'
        % WATER TENSION
        WT          = 1500 .* ones(size(SLDP));
        soilm_parm  = saxton(CLAY, SAND, WT, SD);
    case 'fc'
        % WATER TENSION
        WT          = 33 .* ones(size(SLDP));
        soilm_parm  = saxton(CLAY, SAND, WT, SD);
    case 'alpha'
        a           = -4.396;
        b           = -0.0715;
        c           = -4.880E-4;
        d1           = -4.285E-5;
        soilm_parm  = exp(a + b .* CLAY + c .* SAND .^ 2 + d1 .* SAND .^ ...
                    2 .* CLAY) .* 100;
    case 'beta'
        e           = -3.140;
        f1           = -2.22E-3;
        g           = -3.484E-5;
        soilm_parm  = e + f1 .* CLAY .^ 2 + g .* SAND .^ 2 .* CLAY;
    otherwise
        error(['Unkown soil moisture parameter: ' soil_prm])
end

end % function
