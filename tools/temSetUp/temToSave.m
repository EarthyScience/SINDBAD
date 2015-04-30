function info = temToSave(info)
% state variables to save
% 0 nothing; 
% 1 simple; 
% 2 full;
% 3 cmip5 style;

% save nothing
info.variables.saveState	= {};

% save simple
if info.flags.saveStates >= 1
    info.variables.saveState	= [info.variables.saveState ...
        {'s.cVeg' 's.cLitter' 's.cSoil'}];
    info.variables.saveState	= [info.variables.saveState ...
        {'s.wGW' 's.wSWE' 's.wSM'}];
end

% save full
if info.flags.saveStates == 2
    for ij = 1:14
        info.variables.saveState	= [info.variables.saveState ...
            {['s.cPools(' num2str(ij) ').value']}];
    end
    for ij = 1:numel(info.params.SOIL.HeightLayer)
        info.variables.saveState	= [info.variables.saveState ...
            {['s.smPools(' num2str(ij) ').value']}];
    end
end

end % function