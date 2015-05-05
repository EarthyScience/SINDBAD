function info = temStatesToSave(info)
% state variables to save
% 0 nothing; 
% 1 simple; 
% 2 full;
% 3 cmip5 style;

% save nothing
info.variables.saveState	= {};
info.variables.aggStates    = {};

% save simple
if info.flags.saveStates >= 1
    info.variables.aggStates	= {'cVeg' 'cLitter' 'cSoil'};
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

if info.checks.WBalance
    wbp                         = {'s.wGW','s.wSWE','s.wSM','s.wGWR'};
    tmp                         = unique(horzcat(wbp,info.variables.saveState));
    info.variables.saveState	= tmp;
end

if info.checks.CBalance
    info.variables.aggStates	= [info.variables.aggStates {'cTotal'}];
end

info.variables.aggStates	= unique(info.variables.aggStates);
if ~isempty(info.variables.aggStates)
    cPoolsID    = [];
    for ij = 1:numel(info.variables.aggStates)
        cPoolsID	= [cPoolsID info.helper.cPoolsID4.(info.variables.aggStates{ij})];
    end
    cPoolsID = unique(cPoolsID);
    for ij = cPoolsID
        info.variables.saveState	= [info.variables.saveState ...
            {['s.cPools(' num2str(ij) ').value']}];
    end
end

end % function