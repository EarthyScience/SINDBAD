function [f,fe,fx,s,d,p] = keepStates_simple(f,fe,fx,s,d,p,info,tix)

% if we make that the default function i'll make it fast in the generated
% code (avoiding the eval) and if and else ...

%variables to keep (previous time step)
cvars_source        =   info.tem.model.code.variables.to.keepSource;
cvars_destination	=   info.tem.model.code.variables.to.keepDestination;

for ii  =   1:length(cvars_source)
    sstr            =   [char(cvars_destination(ii)) ' = ' char(cvars_source(ii))];
    eval(sstr);
end
end % function

