function create_empty_file ( ncfile, mode )
% CREATE_EMPTY_FILE:  Does just that, makes an empty netcdf file.
%
% USAGE:  create_empty_file ( ncfile );

if nargin < 2
	mode = nc_clobber_mode;
end
nc_create_empty(ncfile,mode);
return
