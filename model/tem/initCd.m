function d = initCd(d,info)

% initial value for pools
% S   = ones(info.forcing.size) .* 1E-10;
S0	= zeros(info.forcing.size);
% S1	= zeros(info.forcing.size);


% d.CAllocationVeg.c2pool(1).value	= S0;
% d.CAllocationVeg.c2pool(2).value	= S0;
% d.CAllocationVeg.c2pool(3).value	= S0;
% d.CAllocationVeg.c2pool(4).value	= S0;


startvalues             = repmat({S0},1,4);
d.CAllocationVeg.c2pool	= struct('value', startvalues);