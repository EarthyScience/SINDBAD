function Theta = saxton(CLAY, SAND, WT, SD)
% #########################################################################
% Saxton, K.E., W.J. Rawls, J.S. Romberger, and R.I. Papendick. 1986. 
% Estimating generalized soil-water characteristics from texture. 
% Soil Sci. Soc. Am. J. Vol. 50(4):1031-1036.
% http://www.bsyse.wsu.edu/saxton/soilwater/Article.htm
% 
% Theta = saxton(CLAY, SAND, WT, SD);
% 
% Theta : WT == 33      => field capacity (mm)
%       : WT == 1500    => wilting point (mm)
% CLAY  : clay percentage (%)
% SAND  : sand percentage (%)
% WT    : water tension (kPa)
% SD    : soil depth
% #########################################################################

% WATER POTENTIAL, kPa
Psi = WT;

% Coefficients 
a   = -4.396;
b   = -0.0715;
c   = -4.880E-4;
d1   = -4.285E-5;
e   = -3.140;
f1   = -2.22E-3;
g   = -3.484E-5;, 
h   = 0.332;
j   = -7.251E-4;
k   = 0.1276;
m   = -0.108;
n   = 0.341;
p   = 12.012;
q   = -7.55E-2;
r   = -3.8950;
t   = 3.671E-2;
u   = -0.1103;
v   = 8.7546E-4;

% Equations
A   = exp(a + b .* CLAY + c .* SAND .^ 2 + d1 .* SAND .^ 2 .* CLAY) * 100;
B   = e + f1 .* CLAY .^ 2 + g .* SAND .^ 2 .* CLAY;

% WATER CONTENT AT SATURATION (m^3/m^3)
Theta_s = h + j .* SAND + k .* log10(CLAY);

% WATER POTENTIAL AT AIR ENTRY (kPa)
Psi_e   = 100 .* (m + n .* Theta_s);

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

end % function