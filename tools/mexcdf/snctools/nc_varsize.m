function varsize = nc_varsize(ncfile, varname)
%This function is deprecated.  Please use NC_GETVARINFO instead.

%NC_VARSIZE  Return size of requested netCDF variable.
%
%   VARSIZE = NC_VARSIZE(NCFILE,NCVAR) returns the size of the netCDF 
%   variable NCVAR in the netCDF file NCFILE.
%

if ~ischar(ncfile)
	error ( 'SNCTOOLS:NC_VARSIZE:badInputType', 'The input filename must be a string.' );
end
if ~ischar(varname)
	error ( 'SNCTOOLS:NC_VARSIZE:badInputType', 'The input variable name must be a string.' );
end


v = nc_getvarinfo ( ncfile, varname );

varsize = v.Size;

return

