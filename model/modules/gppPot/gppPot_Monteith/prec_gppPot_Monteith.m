function [f,fe,fx,s,d,p] = prec_gppPot_Monteith(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% set the potential GPP based on radiation use efficiency
%
% Inputs:
%   - p.gppPot.maxrue : maximum instantaneous radiation use efficiency [gC/MJ]
%
% Outputs:
%   - d.gppPot.rueGPP: potential GPP based on RUE (nPix,nTix)
%
% Modifies:
%   - 
%
% References:
%   - 
%
% Notes:
%   - set the potential GPP as maxRUE .* PAR (gC/m2/timestep)
%   - no crontrols for fPAR or meteo factors
%   - usually, 
%       GPP     = e_max x f(clim) x FAPAR x PAR
%       here 
%       GPP     = GPPpot x f(clim) x FAPAR
%       GPPpot  = e_max x PAR
%               f(clim) and FAPAR are (maybe) calculated dynamically
%   
% 
% Created by:
%   - Martin Jung (mjung)
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up (changed the output to nPix, nTix)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> set rueGPP to a constant  
d.gppPot.gppPot = p.gppPot.maxrue .* f.PAR;
end
