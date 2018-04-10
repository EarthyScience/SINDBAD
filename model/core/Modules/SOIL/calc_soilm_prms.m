function [Alpha,Beta,WPT,FC] = calc_soilm_prms(p,info)
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
SD  = p.SOIL.HeightLayer(info.helper.SOIL.layer).value;

% CONVERT SAND AND CLAY TO PERCENTAGES
CLAY    = p.SOIL.CLAY .* 100;
SAND    = p.SOIL.SAND .* 100;

% Equations
A   = exp(p.SOIL.a + p.SOIL.b .* CLAY + p.SOIL.c .* SAND .^ 2 + p.SOIL.d1 .* SAND .^ 2 .* CLAY) * 100;
B   = p.SOIL.e + p.SOIL.f1 .* CLAY .^ 2 + p.SOIL.g .* SAND .^ 2 .* CLAY;

% FC and WPT
for WT = [33 1500]
    Psi           = WT .* ones(size(SD));

    % #########################################################################
    % Saxton, K.E., W.J. Rawls, J.S. Romberger, and R.I. Papendick. 1986.
    % Estimating generalized soil-water characteristics from texture.
    % Soil Sci. Soc. Am. J. Vol. 50(4):1031-1036.
    % http://www.bsyse.wsu.edu/saxton/soilwater/Article.htm
    %
    % Theta = saxton(CLAY, SAND, WT, SD);
    %
    % Theta : Psi == 33      => field capacity (mm)
    %       : Psi == 1500    => wilting point (mm)
    % CLAY  : clay percentage (%)
    % SAND  : sand percentage (%)
    % Psi   : water tension (kPa)
    % SD    : soil depth
    % #########################################################################

    % WATER POTENTIAL, Psi, kPa
    
    % WATER CONTENT AT SATURATION (m^3/m^3)
    Theta_s = p.SOIL.h + p.SOIL.j .* SAND + p.SOIL.k .* log10(CLAY);

    % WATER POTENTIAL AT AIR ENTRY (kPa)
    Psi_e   = 100 .* (p.SOIL.m + p.SOIL.n .* Theta_s);

    Theta   = zeros(size(CLAY));
    ndx     = find(Psi >= 10 & Psi <= 1500);
    if ~isempty(ndx)
        % ---------------------------------------------------------------------
        % Psi(ndx) = A(ndx) .* Theta(ndx) .^ B(ndx);
        % ---------------------------------------------------------------------
        Theta(ndx) = (Psi(ndx) ./ A(ndx)) .^ (1 ./ B(ndx));
    end
    clear ndx

    ndx = find(Psi >= Psi_e & Psi < 10);
    if ~isempty(ndx)
        % WATER CONTENT AT 10 kPa (m^3/m^3)
        Theta_10 = exp((2.302 - log(A(ndx))) ./ B(ndx));
        % ---------------------------------------------------------------------
        % Psi(ndx) = 10.0 - (Theta(ndx) - Theta_10(ndx)) .* (10.0 - ...
        %     Psi_e(ndx)) ./ (Theta_s(ndx) - Theta_10(ndx));
        % ---------------------------------------------------------------------
        Theta(ndx) = Theta_10 + (10.0 - Psi(ndx)) .* ...
            (Theta_s(ndx) - Theta_10) ./ (10.0 - Psi_e(ndx));
    end
    clear ndx

    ndx = find(Psi >= 0 & Psi < Psi_e);
    if ~isempty(ndx)
        Theta(ndx) = Theta_s(ndx);
    end
    clear ndx

    % -------------------------------------------------------------------------
    % % WATER CONDUCTIVITY (m/s)
    % K = 2.778E-6 .*(exp(p + q .* SAND + (r + t .* SAND + u .* CLAY + v .*...
    %     CLAY .^ 2) .* (1 ./ Theta)));
    % -------------------------------------------------------------------------

    % ACCOUNT FOR SOIL DEPTH
    Theta = Theta .* SD .* 1000;
    
    if Psi == 33
        FC = Theta;
    elseif Psi == 1500
        WPT = Theta;
    else
        error(['ERR:calc_soil_prms: Psi not known : ' num2str(Psi)])
    end
end

Alpha   = A;
Beta    = B;

end % function
