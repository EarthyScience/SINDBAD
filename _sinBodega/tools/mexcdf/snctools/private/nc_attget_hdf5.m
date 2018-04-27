function attdata = nc_attget_hdf5(ncfile,varname,attname)

if isempty(varname)
    warning('SNCTOOLS:nc_attget:hdf5:doNotUseEmptyVarname', ...
        'Do not use '''' for the variable name, use NC_GLOBAL instead.' );
    varname = '/';
end

% H5ATTGET wants '/' for NC_GLOBAL
if varname == -1
    varname = '/';
end

if strcmpi(varname,'global')
    warning('SNCTOOLS:nc_attget:hdf5:doNotUseGlobalVarname', ...
        'Do not use ''%s'' for the variable name, use NC_GLOBAL instead.', ...
        varname);
    varname = '/';
end

attdata = h5attget(ncfile,varname,attname);

return





