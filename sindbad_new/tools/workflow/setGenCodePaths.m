function info = setGenCodePaths(info)

% unique name for the generated code files according to experiment name and to runDate.
tmpStrName	= [info.experiment.name '_' info.experiment.domain '_' datestr(info.experiment.runDate,30)];
tmpStrName  = strrep(strrep(tmpStrName,' ','_'),'-','_');

% feed that into the structure
info.tem.model.paths.genCode.coreTEM        = ['genCore_' tmpStrName '.m'];
info.tem.model.paths.genCode.preCompOnce    = ['genPrecOnce_' tmpStrName '.m'];
info.tem.spinup.paths.genCode.coreTEM       = ['genCoreSpinup_' tmpStrName '.m'];
info.tem.spinup.paths.genCode.preCompOnce	= ['genPrecOnceSpinup_' tmpStrName '.m'];
info.tem.spinup.paths.genCode.coreTEM       = ['genCoreSpinup_' tmpStrName '.m'];
info.tem.spinup.paths.genCode.preCompOnce   = ['genPrecOnceSpinup_' tmpStrName '.m'];
