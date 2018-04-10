function [fx,fe,d] = PreAllocate(info)

AllVars	= info.variables.all;
sstr    = {'d.','fe.','fx.'};
d       = struct;
fe      = struct;
fx      = struct;

% loop over d, fe, fx
for ii = 1:length(sstr)
    % find respective variables
    v   = find(strncmp(AllVars,sstr{ii},length(sstr{ii})));
    % loop over respective variables
    for jj = 1:length(v)
        % the variable name
        cVar	= AllVars{v(jj)};
        % if the number of 
        % preallocate
%% d.Temp. ...
        if strncmp(cVar,'d.Temp.',length('d.Temp.'))
            eval([cVar ' = info.helper.nan1d;'])
            
%% CCycle - all pools
        elseif strncmp(cVar,'fx.cEfflux',length(cVar))
            poolname        = {'ROOT', 'ROOTC', 'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};
            startvalues     = repmat({info.helper.zeros2d},1,numel(poolname));
            fx.cEfflux      = struct('value', startvalues,'maintenance',startvalues,'growth',startvalues);
            
        elseif strncmp(cVar,'fe.CCycle.annkpool',length(cVar))
            poolname            = {'ROOT', 'ROOTC', 'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};
            startvalues         = repmat({info.helper.nan2d},1,numel(poolname));
            fe.CCycle.annkpool  = struct('value', startvalues);
            
        elseif strncmp(cVar,'fe.CCycle.kpool',length(cVar))
            poolname        = {'ROOT', 'ROOTC', 'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};
            startvalues     = repmat({info.helper.nan2d},1,numel(poolname));
            fe.CCycle.kpool = struct('value', startvalues);
            
        elseif strncmp(cVar,'fe.CCycle.DecayRate',length(cVar))
            poolname            = {'ROOT', 'ROOTC', 'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};
            startvalues         = repmat({info.helper.nan2d},1,numel(poolname));
            fe.CCycle.DecayRate = struct('value', startvalues);
            
        elseif strncmp(cVar,'fe.CCycle.kfEnvTs',length(cVar))
            poolname            = {'ROOT', 'ROOTC', 'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};
            startvalues         = repmat({info.helper.nan2d},1,numel(poolname));
            fe.CCycle.kfEnvTs   = struct('effFLUX',startvalues,'xrtEFF',startvalues);
%% CCycle - tranfers...
        elseif strncmp(cVar,'fe.CCycle.ctransfer',length(cVar))
            startvalues         = repmat({info.helper.nan2d},1,16);
            fe.CCycle.ctransfer = struct('value', startvalues);
            
%% CCycle - vegetation...
        elseif strncmp(cVar,'fx.cNpp',length(cVar))
            startvalues     = repmat({info.helper.zeros2d},1,4);
            fx.cNpp         = struct('value', startvalues);
            
        elseif strncmp(cVar,'d.CAllocationVeg.c2pool',length(cVar))
            startvalues             = repmat({info.helper.nan2d},1,4);
            d.CAllocationVeg.c2pool	= struct('value', startvalues);
            
        elseif strncmp(cVar,'fe.AutoResp.km',length(cVar))
            startvalues     = repmat({info.helper.nan2d},1,4);
            fe.AutoResp.km	= struct('value', startvalues);
            
        elseif strncmp(cVar,'fe.AutoResp.km4su',length(cVar))
            startvalues         = repmat({info.helper.nan2d},1,4);
            fe.AutoResp.km4su	= struct('value', startvalues);
            
        elseif strncmp(cVar,'d.TempEffectAutoResp.fT',length(cVar))
            startvalues         = repmat({info.helper.nan2d},1,4);
            d.TempEffectAutoResp.fT	= struct('value', startvalues);
            
%% CCycle - respiratory fluxes
        elseif strncmp(cVar,'fx.ra',length(cVar)) || strncmp(cVar,'fx.rh',length(cVar)) || strncmp(cVar,'fx.npp',length(cVar))
            eval([cVar ' = info.helper.zeros2d;'])
%% all the rest...
        else
            % disp([cVar ' = info.helper.nan2d;'])
            eval([cVar ' = info.helper.nan2d;'])
        end
    end
end

% preallocate d.statesOut.
cvars	= info.variables.saveState;
for ii = 1:length(cvars)
    % get the actual fieldname
    tmp     = splitZstr(cvars{ii},'.');
    tmpVN   = char(tmp(end));
    % if the name is value, is like, cPools(1).value
    if strcmp(tmpVN,'value')
        tmpVN	= [char(tmp(end-1)) '.' char(tmp(end))];
    end
    if strncmp(cvars{ii},'s.',2) 
        eval(['d.statesOut.' tmpVN ' = info.helper.nan2d;'])
    end    
end

end % function
