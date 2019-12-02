function [f,fe,fx,s,d,p] = prec_cTaufLAI_CASA(f,fe,fx,s,d,p,info)

s.cd.p_cTaufLAI_kfLAI = info.tem.helpers.arrays.onespixzix.c.cEco; %(inefficient, should be pix zix_veg)

TSPY    = info.tem.model.time.nStepsYear; %sujan
% make sure TSPY is integer
if rem(TSPY,1)~=0,TSPY=floor(TSPY);end
% s.cd.p_cTaufLAI_LAI13                 =   repmat(s.cd.LAI,1, TSPY + 1);
% s.cd.p_cTaufLAI_LAI13                 =   repmat(s.cd.LAI,1, TSPY + 1);
if ~isfield(s.cd,'p_cTaufLAI_LAI13')
    s.cd.p_cTaufLAI_LAI13                   =   repmat(info.tem.helpers.arrays.zerospix,1, TSPY + 1);
end


% ORIGINAL
% s.cd.p_cTaufLAI_kfLAI = info.tem.helpers.arrays.onespixzix.c.cEco; %(ineficient, should be pix zix_veg)
% 
% TSPY    = info.tem.model.time.nStepsYear; %sujan
% % make sure TSPY is integer
% if rem(TSPY,1)~=0,TSPY=floor(TSPY);end
% 
% % BUILD AN ANNUAL LAI MATRIX
% LAI13                   =   repmat(info.tem.helpers.arrays.zerospix,1, TSPY + 1);
% LAI13(:, 2:TSPY + 1)    =   flip(d.cLAI.LAI(:,1:TSPY), 2);
% LAI13(:, 1)             =   d.cLAI.LAI(:, 1);
% s.cd.p_cTaufLAI_LAI13   =   LAI13;


end
