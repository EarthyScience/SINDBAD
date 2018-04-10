function CheckInitialisedStates(info,s,d)

AllVars	= info.variables.all;

sstr = {'s.'};%,'d.'}; % -> needs adapting for d as well...
for ii = 1:numel(sstr)
    csstr   = sstr{ii};
    switch csstr
        case 's.';  iniVars = fieldnames(s);
        case 'd.';	iniVars = fieldnames(d);
    end
    for jj = 1:length(AllVars)
        if~strcmp(csstr,AllVars{jj}(1:numel(csstr))),continue,end
        if isempty(strmatch(AllVars{jj}(numel(csstr)+1:end),iniVars,'exact'))
            disp(['CheckInitialisedStates :  not initialized : ' AllVars{jj}])
        end
    end
    for jj = 1:length(iniVars)
        if isempty(strmatch([csstr iniVars{jj}],AllVars,'exact'))
            disp(['CheckInitialisedStates :  not used : ' iniVars{jj}])
        end
    end
end
end