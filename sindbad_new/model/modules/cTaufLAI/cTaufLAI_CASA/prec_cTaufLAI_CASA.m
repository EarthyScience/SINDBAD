function [f,fe,fx,s,d,p] = prec_cTaufLAI_CASA(f,fe,fx,s,d,p,info)


TSPY	= info.timeScale.stepsPerYear;
% make sure TSPY is integer
if rem(TSPY,1)~=0,TSPY=floor(TSPY);end

% BUILD AN ANNUAL LAI MATRIX
LAI13                   = zeros(size(f.LAI,1), TSPY + 1);
LAI13(:, 2:TSPY + 1)	= flip(f.LAI(:,1:TSPY), 2);
LAI13(:, 1)             = f.LAI(:, 1);
p.cTaufLAI.LAI13     	= LAI13;


end % function