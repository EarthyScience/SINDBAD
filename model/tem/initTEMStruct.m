function [fx,fe,d,s] = initTEMStruct(info,varargin)
% initialize model states
    % carbon and water pools
    % maybe also all outputs...
fe	= struct;
fx  = struct;
fx  = initCflux(fx,info);
fx  = initWflux(fx,info);
d   = struct;
d   = initWd(d,info);
d   = initCd(d,info);
s   = struct;
s   = initCpools(s,info);
s   = initWpools(s,info);

if nargin == 3
    sSU	= varargin{1};
    dSU = varargin{2};
    % inherit the state variables
    % carbon
    s.cPools = sSU.cPools;
    % water
    d.Temp.pwSWE(:,1)     = sSU.wSWE(:,end);
    d.Temp.pwSM1(:,1)     = sSU.wSM1(:,end);
    d.Temp.pwSM2(:,1)     = sSU.wSM2(:,end);
    d.Temp.pwGW(:,1)      = sSU.wGW(:,end);
    d.Temp.pwGWR(:,1)     = sSU.wGWR(:,end);
    d.Temp.pwWTD(:,1)     = sSU.wWTD(:,end);
    
    % inherit the diagnostics
    % carbon
    d.CAllocationVeg.c2pool     = dSU.CAllocationVeg.c2pool;
    % water
    d.SaturatedFraction.frSat(:,1)	= dSU.SaturatedFraction.frSat(:,end);
    d.SoilMoistEffectRH.pBGME       = dSU.SoilMoistEffectRH.BGME(:,end);
end


% note: check : IniDummyVariables4Test


end % function