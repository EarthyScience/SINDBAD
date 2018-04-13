function [fx,fe,d,s] = initTEMStruct(info,varargin)
% initialize model states and flux matrices
% carbon and water pools

% set up all the variables as NaN matrices...    
[fx,fe,d]	= PreAllocate(info);

% initialize carbon and water states
s       = struct;
[d,s]	= InitializeVariables(info,d,s);

% check the initialized states and diagnostics
CheckInitialisedStates(info,s,d)
%{
if nargin == 3
    sSU	= varargin{1};
    dSU = varargin{2};
    
    % this should also be automatized...
    % inherit the state variables
    % carbon
    if~isempty(strmatch('cPools',fieldnames(sSU),'exact'))
        s.cPools = sSU.cPools;
    end
    % water
    d.Temp.pwSWE(:,1)     = sSU.wSWE(:,end);
    d.Temp.pwSM(:,1)      = sSU.wSM(:,end);
    d.Temp.pwGW(:,1)      = sSU.wGW(:,end);
    d.Temp.pwGWR(:,1)     = sSU.wGWR(:,end);
%     d.Temp.pwWTD(:,1)     = sSU.wWTD(:,end);
    
    % inherit the diagnostics
    % carbon
    % this is ungly....
    if~isempty(strmatch('CAllocationVeg',fieldnames(d),'exact'))
        d.CAllocationVeg.c2pool     = dSU.CAllocationVeg.c2pool;
    end
    % water
    
    %MJ:
%    s.wFrSat	= sSU.frSat;
    %d.SaturatedFraction.frSat(:,1)	= dSU.SaturatedFraction.frSat(:,end);
    % this is ungly....
    if~isempty(strmatch('SoilMoistEffectRH',fieldnames(d),'exact'))
        d.SoilMoistEffectRH.pBGME       = dSU.SoilMoistEffectRH.BGME(:,end);
    end
    
    % do we also need to inherit other states or factors!?!?
    
end


% note: check : IniDummyVariables4Test
%}

end % function