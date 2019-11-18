function [f,fe,fx,s,d,p] = wSurfRec_fraction(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% calculates surface water recharge as a fraction of Qint_Bergstroem 
% (land runoff that does not increase soil moisture)
%
% Inputs:
%	- fx.QoverFlow: overflow land runoff [mm/time]
%   - p.wSurfRec.rf: fraction of water that contributes to recharge [-]
%
% Outputs:
%   - fx.QsurfDir: fast runoff [mm/time]
%   - fx.wSurfRec: surface water recharge [mm/time]
%
% Modifies:
% 	- s.w.wSurf: surface water pool [mm]
%
% References:
%	- 
%
% Created by:
%   - Martin Jung (mjung@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% #########################################################################

% calculate recharge
fx.wSurfRec(:,tix)  = p.wSurfRec.rf .* fx.QoverFlow(:,tix);

% calculate direct runoff
% POSSIBLE: add this tmp_QsurfDir to WBP and transfer still available WBP
% to QsurfDir later on
fx.QsurfDir(:,tix)  = (1-p.wSurfRec.rf) .* fx.QoverFlow(:,tix);

% update surface water pool
s.w.wSurf = s.w.wSurf + fx.wSurfRec(:,tix);

end
