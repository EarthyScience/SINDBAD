function [f,fe,fx,s,d,p] = prec_cTaufLAI_CASA(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % set LAI stressor on tau to ones
    %
    % Inputs:
    %   - info.timeScale.stepsPerYear:   number of years of simulations     
    %
    % Outputs:
    %   - s.cd.p_cTaufLAI_kfLAI: 

    % Modifies:
    %   - 
    %
    % References:
    % - 
    %
    % Created by:
    %   - ncarvalhais
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% set LAI stressor on tau to ones
s.cd.p_cTaufLAI_kfLAI = info.tem.helpers.arrays.onespixzix.c.cEco; %(inefficient, should be pix zix_veg)

TSPY    = info.tem.model.time.nStepsYear; %sujan
% make sure TSPY is integer
if rem(TSPY,1)~=0,TSPY=floor(TSPY);end

if ~isfield(s.cd,'p_cTaufLAI_LAI13')
    s.cd.p_cTaufLAI_LAI13                   =   repmat(info.tem.helpers.arrays.zerospix,1, TSPY + 1);
end

end
