function values = nc_attget_tmw(ncfile, varname, attribute_name )

ncid = netcdf.open(ncfile,nc_nowrite_mode);
try

    switch class(varname)
    case { 'double' }
        varid = varname;

    case 'char'
        varid = figure_out_varid_tmw ( ncid, varname );

    otherwise
        error('SNCTOOLS:NC_ATTGET:badType', ...
            'Must specify either a variable name or NC_GLOBAL' );

    end

    values = netcdf.getAtt(ncid,varid,attribute_name);
	netcdf.close(ncid);
	return

catch me
	netcdf.close(ncid);
    rethrow(me);
end
return













%--------------------------------------------------------------------------
function varid = figure_out_varid_tmw ( ncid, varname )
% Did the user do something really stupid like say 'global' when they meant
% NC_GLOBAL?
if isempty(varname)
    varid = nc_global;
    return;
end

if ( strcmpi(varname,'global') )
    try 
        varid = netcdf.inqVarID(ncid,varname);
        return
    catch %#ok<CTCH>
        %
        % Ok, the user meant NC_GLOBAL
        warning ( 'SNCTOOLS:nc_attget:doNotUseGlobalString', ...
                  ['Please consider using the m-file NC_GLOBAL.M ' ...
                   'instead of the string ''%s''.'], varname );
        varid = nc_global;
        return;
    end
else
    varid = netcdf.inqVarID(ncid,varname);
end



