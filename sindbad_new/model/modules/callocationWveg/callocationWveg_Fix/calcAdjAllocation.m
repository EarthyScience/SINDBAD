function [d] = calcAdjAllocation(f,fe,fx,s,d,p,info,tix)
% adjust the allocation coefficients according to the fraction of
% trees to herbaceous and fine to coarse root partitioning

% TreeCover and fine to coarse root ratio
tc      = p.pvegR.TreeCover;
rf2rc	= p.callocationWveg.Rf2Rc;

% the allocation fractions according to the partitioning to root/wood/leaf
% - represents plant level allocation
r0	= d.callocationWveg.cf2Root(:,tix); % this is to below ground root fine+coarse
s0	= d.callocationWveg.cf2Wood(:,tix);
l0	= d.callocationWveg.cf2Leaf(:,tix);

% adjust for spatial consideration of TreeCover and plant level
% partitioning between fine and coarse roots
rf1 = r0 .* tc .* rf2rc + (r0 + s0 .* (r0 ./ (r0 + l0))) .* (1 - tc);
rc1 = r0 .* tc .* (1 - rf2rc);
s1  = s0 .* tc + 0;
l1	= l0 .* tc + (l0 + s0 .* (l0 ./ (r0 + l0))) .* (1 - tc);

% feed it to d
d.callocationWveg.c2pool(1).value(:,tix)	= rf1;
d.callocationWveg.c2pool(2).value(:,tix)  = rc1;
d.callocationWveg.c2pool(3).value(:,tix)  = s1;
d.callocationWveg.c2pool(4).value(:,tix)	= l1;

end % function