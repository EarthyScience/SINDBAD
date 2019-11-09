function [f,fe,fx,s,d,p] = storeStates_simple(f,fe,fx,s,d,p,info,tix)

% if we make that the default function i'll make it fast in the generated
% code (avoiding the eval) and if and else ...
cvars_source        =   info.tem.model.code.variables.to.storeStatesSource;
cvars_destination	=   info.tem.model.code.variables.to.storeStatesDestination;


% added by sujan on 09.11.2019 to create all the stored states arrays at
% the beginning of the model simulation at t=1 when all the s. variables
% are already available, and their sizes can be inferred

if tix == 1
    numTimeStr              =   num2str(info.tem.helpers.sizes.nTix);
    for ij                  =	1:numel(cvars_source)
        var2ss              =   cvars_source{ij}(1:end-1);
        var2sdtmp           =   strsplit(cvars_destination{ij},'(');
        var2sd              =   var2sdtmp{1};
        evalStr             =   [var2sd ' = reshape(repelem(' var2ss ',1,' numTimeStr '),[size(' var2ss '),' numTimeStr ']);'];
        eval(evalStr)
    end
end
% --> end of array creation
%%

for ii  =   1:length(cvars_source)
    sstr            =   [char(cvars_destination{ii}) ' = ' char(cvars_source(ii)) ';'];
    eval(sstr);
end

end % function

