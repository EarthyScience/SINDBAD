function [fx,s,d] = dyna_Qbase_Orth2013(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates delayed runoff and 'ground water' storage
% 
% REFERENCES: Orth et al. 2013
% 
% CONTACT	: ttraut
% 
% INPUT
% Qint      : runoff from land [mm/time]
%           (fx.Qint)
% Rdelay 	: delay function of Qint as defined by qt parameter
% 			(fe.Rdelay)
% wGW       : ground water pool [mm] 
%           (s.wGW)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% OUTPUT
% Q         : final flow [mm/time]
%           (fx.Q)
% Qb        : base flow [mm/time]
%           (fx.Qb)
% wGW       : ground water pool [mm] 
%           (s.wGW)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
%
% NOTES: how to handle 60days?!?!
% 
% #########################################################################

% calculate Q from delay of previous days
if i>60
	tmin = max(i-60,1);
	fx.Q(:,tix) = sum(fx.Qint(:,tmin:i) .* fe.Rdelay,2);		
else % or accumulate land runoff in GW
	fx.Q(:,tix) = 0;
end

% update the GW pool
s.wGW = s.wGW + fx.Qint(:,tix) - fx.Q(:,tix);

% Qb for water balance check
fx.Qb(:,tix) = fx.Q(:,tix) - fx.Qint(:,tix);

end
