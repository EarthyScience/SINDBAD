function [f,fe,fx,s,d,p] = prec_EvapSoil_Snyder2000(f,fe,fx,s,d,p,info)
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
%           (p.EvapSoil.alpha); ; range ~ [0.5 1.5]
% beta      : soil hydraulic parameter [sqrt(mm/time)]
%           : p.EvapSoil.beta; range ~ [1 5]
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (f.FAPAR)
%rainfall   :mm/time
%
% 
% OUTPUT
% ETsoil   : evaporation from the soil surface [mm/time]
%           (fe.EvapSoil.PETsoil)
% 
% NOTES:
% 
% #########################################################################


%sPET_old: sum of PET since last precip event
%sET: sum of ET  since last precip event


palpha              = p.EvapSoil.alpha * ones(1,info.forcing.size(2));
PET                 = f.PET .* palpha .* (1 - f.FAPAR);
PET(PET<0)          = 0;


fe.EvapSoil.PETsoil=PET;

%initialise
sPET_old = PET(:,1);
sET      = zeros(size(sPET_old)); %sET from last time step
isdry    = zeros(size(sET)); %is basically a logical flag
sPET     = zeros(size(sET));

ET       = zeros(size(PET));
ET2       = zeros(size(PET));%for conditions with light rainfall which were considered not as a
%wetting event
ET(:,1)  = PET(:,1);

beta2=p.EvapSoil.beta.*p.EvapSoil.beta;
%precip_threshold
%precip_threshold=3.*PET;
%loop over time
for it=2:size(PET,2)
    %isdry(:)   = f.Rain(:,it)==0;
    isdry(:)   = f.Rain(:,it) - fx.ECanop(:,it) < PET(:,it); %assume wetting occurs with precip-interception > pet_soil; Snyder argued one should use precip > 3*pet_soil but then it becomes inconsistent here
    sPET(:)    = isdry.*(sPET_old+PET(:,it));
    issat      = sPET > beta2; %same as sqrt(sPET) > beta (see paper); issat is a flag for stage 2 evap (name 'issat' not correct here)
    ET(:,it)   = isdry.*(~issat .* sPET+issat .* sqrt(sPET) .* p.EvapSoil.beta - sET) + ~isdry .* PET(:,it);
    %
    %correct for conditions with light rainfall which were considered not as a
    %wetting event; for these conditions we assume soil_evap=min(precip-ECanop,pet_soil-evap soil already used)
    ET2(:,it2) = min( f.Rain(:,it) - fx.ECanop(:,it) , PET(:,it) - ET(:,it));
    %[sPET ET(:,it) sET(:) issat]
    sET(:)     = isdry.*(sET+ET(:,it));
    sPET_old(:)= sPET(:);
end






fe.EvapSoil.ETsoil = ET + ET2;

end