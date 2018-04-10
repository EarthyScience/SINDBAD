function [d] = adjAllocation(f,fe,fx,s,d,p,info,i)
% adjust the allocation coefficients according to the fraction of
% trees to herbaceous and fine to coarse root partitioning

% TreeCover and fine to coarse root ratio
tc      = p.VEG.TreeCover;
rf2rc	= p.CAllocationVeg.Rf2Rc;

% the allocation fractions according to the partitioning to root/wood/leaf
% - represents plant level allocation
r0	= d.CAllocationVeg.cf2Root(:,i); % this is to below ground root fine+coarse
s0	= d.CAllocationVeg.cf2Wood(:,i);
l0	= d.CAllocationVeg.cf2Leaf(:,i);

% adjust for spatial consideration of TreeCover and plant level
% partitioning between fine and coarse roots
rf1 = r0 .* tc .* rf2rc + (r0 + s0 .* (r0 ./ (r0 + l0))) .* (1 - tc);
rc1 = r0 .* tc .* (1 - rf2rc);
s1  = s0 .* tc + 0;
l1	= l0 .* tc + (l0 + s0 .* (l0 ./ (r0 + l0))) .* (1 - tc);

% feed it to d
d.CAllocationVeg.c2pool(1).value(:,i)	= rf1;
d.CAllocationVeg.c2pool(2).value(:,i)  = rc1;
d.CAllocationVeg.c2pool(3).value(:,i)  = s1;
d.CAllocationVeg.c2pool(4).value(:,i)	= l1;

end % function