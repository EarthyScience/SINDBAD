function [f,fe,fx,s,d,p] = dyna_roBase_Orth2013(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates delayed runoff and 'ground water' storage
% 
% REFERENCES: Orth et al. 2013
% 
% CONTACT	: ttraut
% 
% INPUT
% roInt      : runoff from land [mm/time]
%           (fx.roInt)
% Rdelay 	: delay function of roInt as defined by qt parameter
% 			(fe.Rdelay)
% wGW       : ground water pool [mm] 
%           (s.w.wGW)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% OUTPUT
% Q         : final flow [mm/time]
%           (fx.Q)
% roBase        : base flow [mm/time]
%           (fx.roBase)
% wGW       : ground water pool [mm] 
%           (s.w.wGW)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
%
% NOTES: how to handle 60days?!?!
% 
% #########################################################################

% calculate Q from delay of previous days
if tix>60
	tmin = maxsb(tix-60,1);
	fx.roTotal(:,tix) = sum(fx.roInt(:,tmin:tix) .* fe.roBase.Rdelay,2);		
else % or accumulate land runoff in GW
	fx.roTotal(:,tix) = 0;
end

% update the GW pool
s.w.wGW = s.w.wGW + fx.roInt(:,tix) - fx.roTotal(:,tix);

% roBase for water balance check
fx.roBase(:,tix) = fx.roTotal(:,tix) - fx.roInt(:,tix);

end
