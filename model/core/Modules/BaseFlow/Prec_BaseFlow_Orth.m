function [fe,fx,d,p] = Prec_BaseFlow_Orth(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: calculates the delay proportion for runoff
% 
% REFERENCES: Orth et al. 2013
% 
% CONTACT	: ttraut
% 
% INPUT
% qt        : delay parameter [time]
%           (p.BaseFlow.qt)
% Rain 		: to get size(1)
%        	(f.Rain)
% 
% OUTPUT
% Rdelay 	: delay function of Qint as defined by qt parameter
% 			(fe.Rdelay)
%
% NOTES: still includes repmat!
% 
% #########################################################################

% calculate delay function of previous days
z           = exp(-(ones(info.forcing.size(1),1) * (0:60) ./ (p.BaseFlow.qt * ones(1,61)))) - exp(((ones(info.forcing.size(1),1) * (0:60)+1) ./ (p.BaseFlow.qt * ones(1,61)))); 
fe.Rdelay   = z./(sum(z,2) * ones(1,61));
%   = repmat(z,[size(f.Rain,1),1]);


end