function [f,fe,fx,s,d,p] = dyna_evapSoil_Snyder2000(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: Snyder et al 2000
% 
% CONTACT	: mjung
% 
% INPUT
% PET       : potential evapotranspiration [mm/time]
%           (f.PET)
% ECanop    : interception evaporation [mm/time]
%           (fx.ECanop)
% alpha     : Priestley-Taylor coefficient []
%           (p.evapSoil.alpha); ; range ~ [0.5 1.5]
% beta      : soil hydraulic parameter [sqrt(mm/time)]
%           : p.evapSoil.beta; range ~ [1 5]
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (s.cd.fAPAR)
%rainfall   :mm/time
%
% 
% OUTPUT
% ETsoil   : evaporation from the soil surface [mm/time]
%           (fe.evapSoil.PETsoil)
% 
% NOTES:
% 
% #########################################################################

rain                        =   fe.rainSnow.rain(:,tix);
PET                         =   f.PET(:,tix) .* p.evapSoil.alpha .* (1 - s.cd.fAPAR);
PET(PET<0)                  =   0;

beta2                       =   p.evapSoil.beta .* p.evapSoil.beta;
isdry                       =   s.wd.WBP < PET; %assume wetting occurs with precip-interception > pet_soil; Snyder argued one should use precip > 3*pet_soil but then it becomes inconsistent here
sPET                        =   isdry .* (s.wd.p_evapSoil_sPETOld + PET);
issat                       =   sPET > beta2; %same as sqrt(sPET) > beta (see paper); issat is a flag for stage 2 evap (name 'issat' not correct here)
ET                          =   isdry.*(~issat .* sPET + issat .* sqrt(sPET) .* p.evapSoil.beta - sET) + ~isdry .* PET;
%
%correct for conditions with light rainfall which were considered not as a
%wetting event; for these conditions we assume soil_evap=min(precip-ECanop,pet_soil-evap soil already used)
ET2                         =   min(s.wd.WBP, PET-ET);
%[sPET ET(:,it) sET(:) issat]
sET                         =   isdry.*(sET+ET);
s.wd.p_evapSoil_sPETOld     =   sPET;


ETsoil                      =   ET + ET2;
fx.evapSoil(:,tix)          =   min(ETsoil, s.w.wSoil(:,1));
% update soil moisture of upper layer
s.w.wSoil(:,1)              =   s.w.wSoil(:,1) - fx.evapSoil(:,tix);

end