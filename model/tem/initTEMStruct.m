function [fx,fe,d,s] = initTEMStruct(info,varargin)
% initialize model states
    % carbon and water pools
    % maybe also all outputs...
fe	= struct;
fx  = struct;
fx  = initCflux(fx,info);
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
    s.wSWE(:,1)     = sSU.wSWE(:,end);
    s.wSM1(:,1)     = sSU.wSM1(:,end);
    s.wSM2(:,1)     = sSU.wSM2(:,end);
    s.wpSM1(:,1)    = sSU.wpSM1(:,end);
    s.wpSM2(:,1)    = sSU.wpSM2(:,end);
    s.wGW(:,1)      = sSU.wGW(:,end);
    s.wGWR(:,1)     = sSU.wGWR(:,end);
    s.wWTD(:,1)     = sSU.wWTD(:,end);
    % inherit the diagnostics
    % carbon
    d.CAllocationVeg.c2pool     = dSU.CAllocationVeg.c2pool;
    % water
    d.SaturatedFraction.frSat(:,1)	= dSU.SaturatedFraction.frSat(:,end);
    d.SoilMoistEffectRH.pBGME       = dSU.SoilMoistEffectRH.BGME(:,end);
end