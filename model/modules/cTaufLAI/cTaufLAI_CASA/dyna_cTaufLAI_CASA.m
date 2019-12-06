function [f,fe,fx,s,d,p] = dyna_cTaufLAI_CASA(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% FUNCTION    : cTaufLAI_CASA
%
% PURPOSE    : compute the seasonal cycle of litter fall and root litter
%           "fall" based on LAI variations. Necessarily in precomputation
%           mode...
%
% REFERENCES:
% Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
% Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
% production: A process model based on global satellite and surface data.
% Global Biogeochemical Cycles. 7: 811-841.
%
% CONTACT    : Nuno
%
% INPUT
% lai           : leaf area index (m2/m2)
%               (f.LAI)
% maxMinLAI     : parameter for the maximum value for the minimum LAI
%               (m2/m2)
%               (p.cTaufLAI.maxMinLAI)
% kRTLAI        : parameter for the constant fraction of root litter imputs
%               to the soil ([])
%               (p.cTaufLAI.kRTLAI)
% stepsPerYear    : number of time steps per year
%               (info.timeScale.stepsPerYear)
% NYears        : number of years of simulations
%               (info.timeScale.nYears)
%
% OUTPUT
% LTLAI         : litter scalar ([])
%               (fe.cCycle.LTLAI)
% RTLAI         : root litter scalar ([])
%               (fe.cCycle.RTLAI)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% % BUILD AN ANNUAL LAI MATRIX
% LAI13                   =   repmat(info.tem.helpers.arrays.zerospix,1, TSPY + 1);
% LAI13(:, 2:TSPY + 1)    =   flip(d.LAI.LAI(:,1:TSPY), 2);
% LAI13(:, 1)             =   d.LAI.LAI(:, 1);
% s.cd.p_cTaufLAI_LAI13   =   LAI13;



% PARAMETERS
maxMinLAI                       =   p.cTaufLAI.maxMinLAI;
kRTLAI                          =   p.cTaufLAI.kRTLAI;


%%%%%NEW

%--> Get the number of time steps per year
TSPY                            =   info.tem.model.time.nStepsYear;
% make sure TSPY is integer
if rem(TSPY,1)~=0,TSPY=floor(TSPY);end

% BUILD AN ANNUAL LAI MATRIX
%--> get the LAI of previous time step in LAI13
LAI13                           =   s.cd.p_cTaufLAI_LAI13;
LAI13(:, 2:TSPY + 1)            =   LAI13(:,1:TSPY);
LAI13(:, 1)                     =   s.cd.LAI;

%--> update s
s.cd.p_cTaufLAI_LAI13           =   LAI13;

%%%%NEW END

% 
% %%%%% OLD
% % BUILD AN ANNUAL LAI MATRIX
% LAI13     = s.cd.p_cTaufLAI_LAI13;
% 
% % FEED LAI13
% LAI13(:, 2:TSPY + 1) = LAI13 (:, 1:TSPY);
% LAI13(:, 1) = d.LAI.LAI(:,tix);
% 
% %%% OLD END

%--> Calculate sum of deltaLAI over the year
dLAIsum                         =   LAI13(:, 2:TSPY + 1) - LAI13(:, 1:TSPY);
dLAIsum(dLAIsum < 0)            =   0;
dLAIsum                         =   sum(dLAIsum, 2);


%--> Calculate average and minimum LAI
LAIave                          =   mean(LAI13(:, 2:TSPY + 1), 2);
LAImin                          =   min(LAI13(:, 2:TSPY + 1), [], 2);
LAImin(LAImin > maxMinLAI)      =   maxMinLAI(LAImin > maxMinLAI);
LAIsum                          =   sum(LAI13(:, 2:TSPY + 1), 2);


%--> Calculate constant fraction of LAI (LTCON)
LTCON                           =   zeros(size(LAI13(:, 1)));
ndx                             =   (LAIave > 0);
LTCON(ndx)                      =   LAImin(ndx) ./ LAIave(ndx);


%--> Calculate deltaLAI
dLAI                            =   LAI13(:, 2) - LAI13(:, 1);
dLAI(dLAI < 0)                  =   0;


%--> Calculate variable fraction of LAI (LTCON)
LTVAR                           =   zeros(size(dLAI));
LTVAR(dLAI <= 0 | dLAIsum <= 0)    =   0;
ndx                             =   (dLAI > 0 | dLAIsum > 0);
LTVAR(ndx)                      =   (dLAI(ndx) ./ dLAIsum(ndx));


%--> Calculate the scalar for litterfall
LTLAI                           =   LTCON ./ TSPY + (1 - LTCON) .* LTVAR;

%--> Calculate the scalar for root litterfall
RTLAI                           =   zeros(size(LTLAI));
ndx                             =   (LAIsum > 0);
LAI131st                        =   LAI13(:, 1);
RTLAI(ndx)                      =   (1 - kRTLAI) .* (LTLAI(ndx) + LAI131st(ndx) ./ ...
                                    LAIsum(ndx)) ./ 2 + kRTLAI ./ TSPY;


%--> Feed the output fluxes to cCycle components
zix                             =   info.tem.model.variables.states.c.zix.cVegLeaf;
s.cd.p_cTaufLAI_kfLAI(:,zix)    =   s.cd.p_cCycleBase_annk(:,zix) .* LTLAI ./ s.cd.p_cCycleBase_k(:,zix); % leaf litter scalar
if isfield(info.tem.model.variables.states.c.zix,'cVegRootF')
    zix = info.tem.model.variables.states.c.zix.cVegRootF;
else
    zix = info.tem.model.variables.states.c.zix.cVegRoot;
end
s.cd.p_cTaufLAI_kfLAI(:,zix)    =   s.cd.p_cCycleBase_annk(:,zix) .* RTLAI ./ s.cd.p_cCycleBase_k(:,zix); % root litter scalar
end
