function [f,fe,fx,s,d,p] = prec_cCycle_CASA(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Calculate decay rates for the ecosystem C pools at appropriate
    % time steps
    %
    % Inputs:
    %   - info.tem.model.time.nStepsYear:   number of time steps per year
    %   - s.cd.p_cCycleBase_annk:               carbon allocation matrix 
    %
    % Outputs:
    %   - s.cd.p_cCycleBase_k:  decay rates for the carbon pool at each time step
    %   - s.cd.cEcoEfflux:      
    %
    % Modifies:
    %   - 
    %
    % References:
    %   - Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
    %     Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
    %     production: A process model based on global satellite and surface data.
    %     Global Biogeochemical Cycles. 7: 811-841.
    %
    % Created by:
    %   - ncarvalhais 
    %
    % Versions:
    %   - 1.0 on 28.02.2020 (sbesnard)
    %
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% NUMBER OF TIME STEPS PER YEAR
TSPY                =   info.tem.model.time.nStepsYear;
% s.prev.cTaufwSoil_fwSoil=info.tem.helpers.arrays.onespixzix.c.cEco; %sujan
s.cd.p_cCycleBase_k    =   1 - (exp(-s.cd.p_cCycleBase_annk) .^ (1 / TSPY));
s.cd.cEcoEfflux     =   info.tem.helpers.arrays.zerospixzix.c.cEco; %sujan moved from get states

end