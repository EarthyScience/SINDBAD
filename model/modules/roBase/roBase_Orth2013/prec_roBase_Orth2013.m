function [f,fe,fx,s,d,p] = prec_roBase_Orth2013(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: calculates the delay proportion for runoff
% 
% REFERENCES: Orth et al. 2013
% 
% CONTACT	: ttraut
% 
% INPUT
% qt        : delay parameter [time]
%           (p.roBase.qt)
% Rain 		: to get size(1)
%        	(f.Rain)
% 
% OUTPUT
% Rdelay 	: delay function of roInt as defined by qt parameter
% 			(fe.Rdelay)
%
% NOTES: still includes repmat!
% 
% #########################################################################

% calculate delay function of previous days
z                  =    exp(-(info.tem.helpers.arrays.onespix * (0:60) ./ (p.roBase.qt * ones(1,61)))) - exp(((info.tem.helpers.arrays.onespix * (0:60)+1) ./ (p.roBase.qt * ones(1,61)))); 
fe.roBase.Rdelay   =    z./(sum(z,2) * ones(1,61));

end