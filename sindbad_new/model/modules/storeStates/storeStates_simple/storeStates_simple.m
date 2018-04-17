function [f,fe,fx,s,d,p] = storeStates_simple(f,fe,fx,s,d,p,info,tix)

% if we make that the default function i'll make it fast in the generated
% code (avoiding the eval) and if and else ...

%variables to keep (previous time step)
cvars_source	= info.tem.model.code.variables.to.keepSource;
cvars_destination	= info.tem.model.code.variables.to.keepDestination;

for ii=1:length(cvars_source)
    sstr=[char(cvars_destination(ii)) ' = ' char(cvars_source(ii))];
    eval(sstr);
end

%states to store (previous time step)
cvars_source	= info.tem.model.code.variables.to.storeStatesSource;
cvars_destination	= info.tem.model.code.variables.to.storeStatesDestination;

for ii=1:length(cvars_source)
    sstr=[char(erase(cvars_destination{ii},';')) ' = ' char(cvars_source(ii)) ';'];
%     sstr=[char(erase(cvars_destination(ii),';')) ' = ' char(cvars_source(ii))];
    eval(sstr);
end



end % function

