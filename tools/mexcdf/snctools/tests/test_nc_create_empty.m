function test_nc_create_empty ( ncfile )
%
% Test:  Supply no arguments.
% Test:  No mode given
% Test:  64-bit mode
% Test:  create a netcdf-4 file
% test_char_mode:  the mode is a string instead of numeric

fprintf('Testing NC_CREATE_EMPTY... \n' );

if nargin < 1
	ncfile = 'foo.nc';
end

test_no_args;                          % #1
test_no_mode_given ( ncfile );         % #2
test_64bit_mode ( ncfile );            % #3
test_netcdf4_classic ( ncfile );       % #4

test_char_mode ( ncfile );             % #5

fprintf('OK\n');
return





%--------------------------------------------------------------------------
function test_hdf4(hfile)

nc_create_empty(hfile,'hdf4');
sd_id = hdfsd('start',hfile,0);
if sd_id < 0
    error('failed');
else
	hdfsd('end',sd_id);
end

%--------------------------------------------------------------------------
function test_netcdf4_classic ( ncfile )

if ~netcdf4_capable
	fprintf('\tmexnc (netcdf-4) backend testing filtered out on configurations where the library version < 4.\n');
	return
end


delete(ncfile);
nc_create_empty(ncfile,nc_netcdf4_classic);
fid = fopen(ncfile,'r');
x = fread(fid,4,'uint8=>char');
fclose(fid);

if ~strcmp(x(2:4)','HDF')
	error('Did not create a netcdf-4 file');
end
return








%--------------------------------------------------------------------------
function test_no_args ( )

try
	nc_create_empty;
	error( 'succeeded when it should have failed');
catch %#ok<CTCH>
    return
end

return







%--------------------------------------------------------------------------
function test_no_mode_given ( ncfile )

nc_create_empty ( ncfile );
md = nc_info ( ncfile );

if ~isempty(md.Dataset)
	error('number of variables was not zero');
end

if ~isempty(md.Attribute)
	error('number of global attributes was not zero');
end

if ~isempty(md.Dimension)
	error('number of dimensions was not zero');
end

return






%--------------------------------------------------------------------------
function test_64bit_mode ( ncfile )

mode = bitor ( nc_clobber_mode, nc_64bit_offset_mode );

nc_create_empty ( ncfile, mode );
md = nc_info ( ncfile );

if ~isempty(md.Dataset)
	error('number of variables was not zero');
end

if ~isempty(md.Attribute)
	error('number of global attributes was not zero');
end

if ~isempty(md.Dimension)
	error('number of dimensions was not zero');
end

return



%--------------------------------------------------------------------------
function test_char_mode ( ncfile )

mode = 'clobber';

nc_create_empty ( ncfile, mode );
md = nc_info ( ncfile );

if ~isempty(md.Dataset)
	error('number of variables was not zero');
end

if ~isempty(md.Attribute)
	error('number of global attributes was not zero');
end

if ~isempty(md.Dimension)
	error('number of dimensions was not zero');
end

return


