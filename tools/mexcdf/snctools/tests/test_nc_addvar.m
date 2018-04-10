function test_nc_addvar ( ncfile )
% TEST_NC_ADDVAR
%
% Relies upon nc_getvarinfo.

% Test: no inputs
% test:  too many inputs
% test:  2nd input not character
% test:  3rd input not numeric
% test:  Add a double variable, no dimensions
% test:  Add a float variable
% test:  Add a int32 variable
% test:  Add a int16 variable
% test:  Add a byte variable
% test:  Add a char variable
% test:  Add a variable with a named fixed dimension.
% test:  Add a variable with a named unlimited dimension.
% test:  Add a variable with a named unlimited dimension and named fixed dimension.
% test:  Add a variable with attribute structures.
% test:  Add a variable with a numeric Datatype
% test:  Try to add a variable that is already there.
% test 19:  Have an illegal field.

% netcdf-4 tests
%     1D no chunking
%     1D chunking
%     2D chunking
%     shuffle
%     deflate
%     chunking + shuffle + deflate

fprintf('Testing NC_ADDVAR ...\n');

if nargin == 0
	ncfile = 'foo.nc';
end

run_nc3_tests(ncfile);
run_hdf4_tests('foo.hdf');
run_nc4_tests(ncfile);

fprintf('OK\n');
return


%--------------------------------------------------------------------------
function run_nc3_tests(ncfile)

fprintf('\tRunning netcdf-3 tests...  ' );
create_mode = nc_clobber_mode;

test_no_inputs;
test_too_many_inputs ( ncfile, create_mode );
test_2nd_input_not_char ( ncfile, create_mode );
test_empty_struct ( ncfile, create_mode );
test_singletons ( ncfile, create_mode );
test_fixed_dimension ( ncfile, create_mode );
test_unlimited ( ncfile, create_mode );
test_unlimited_plus_fixed ( ncfile, create_mode );
test_with_attributes ( ncfile, create_mode );
test_numeric_nctype ( ncfile, create_mode );
test_var_already_there ( ncfile, create_mode );
test_illegal_field_name ( ncfile, create_mode );
fprintf('OK\n');

return






%--------------------------------------------------------------------------
function run_hdf4_tests(ncfile)

fprintf('\tRunning HDF4 tests...  ' );
create_mode = 'hdf4';

test_unlimited ( ncfile, create_mode );
test_unlimited_plus_fixed ( ncfile, create_mode );
test_with_attributes ( ncfile, create_mode );
fprintf('OK\n');

return







%--------------------------------------------------------------------------
function run_nc4_tests(ncfile)

if ~netcdf4_capable
	fprintf('\tmexnc (netcdf-4) backend testing filtered out on configurations where the library version < 4.\n');
	return
end

fprintf('\tRunning netcdf-4 tests...  ' );
create_mode = nc_netcdf4_classic;

test_no_inputs;
test_too_many_inputs ( ncfile, create_mode );
test_2nd_input_not_char ( ncfile, create_mode );
test_empty_struct ( ncfile, create_mode );
test_singletons ( ncfile, create_mode );
test_fixed_dimension ( ncfile, create_mode );
test_unlimited ( ncfile, create_mode );
test_unlimited_plus_fixed ( ncfile, create_mode );
test_with_attributes ( ncfile, create_mode );
test_numeric_nctype ( ncfile, create_mode );
test_var_already_there ( ncfile, create_mode );
test_illegal_field_name ( ncfile, create_mode );

test_1d_no_chunking(ncfile);
test_1d_chunking(ncfile);
test_2d_chunking(ncfile);
test_2d_bad_chunking(ncfile);
test_2d_shuffle(ncfile);
test_2d_deflate(ncfile);
test_2d_chunking_shuffle_deflate(ncfile);
fprintf('OK\n');
return



%--------------------------------------------------------------------------
function test_1d_no_chunking (ncfile)


nc_create_empty (ncfile,nc_netcdf4_classic);
nc_adddim ( ncfile, 'x', 500 );

clear varstruct;
varstruct.Name = 'x';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'x' };
varstruct.Storage = 'contiguous';
varstruct.Chunking = [];

nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo(ncfile,'x');


if ~isempty(v.Chunking) 
	error('1D contiguous size test failed');
end













%--------------------------------------------------------------------------
function test_1d_chunking (ncfile)


nc_create_empty (ncfile,nc_netcdf4_classic);
nc_adddim ( ncfile, 'x', 500 );

clear varstruct;
varstruct.Name = 'x';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'x' };
varstruct.Chunking = 10;

nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo(ncfile,'x');

if v.Chunking ~= 10
	error('1D chunking size test failed');
end











%--------------------------------------------------------------------------
function test_2d_chunking (ncfile)


nc_create_empty (ncfile,nc_netcdf4_classic);
nc_adddim ( ncfile, 'x', 500 );
nc_adddim ( ncfile, 'y', 100 );

clear varstruct;
varstruct.Name = 'z';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'y', 'x' };
varstruct.Chunking = [10 50];

nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo(ncfile,'z');

if (v.Chunking(1) ~= 10) || (v.Chunking(2) ~= 50)
	error('2D chunking size test failed');
end




%--------------------------------------------------------------------------
function test_2d_bad_chunking (ncfile)


nc_create_empty (ncfile,nc_netcdf4_classic);
nc_adddim ( ncfile, 'x', 500 );
nc_adddim ( ncfile, 'y', 100 );

clear varstruct;
varstruct.Name = 'z';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'y', 'x' };
varstruct.Chunking = [40 50 10];

try
	nc_addvar ( ncfile, varstruct );
catch %#ok<CTCH>
	return
end
error('test succeeded when it should have failed');




%--------------------------------------------------------------------------
function test_2d_shuffle (ncfile)


nc_create_empty (ncfile,nc_netcdf4_classic);
nc_adddim ( ncfile, 'x', 500 );
nc_adddim ( ncfile, 'y', 100 );

clear varstruct;
varstruct.Name = 'z';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'y', 'x' };
varstruct.Shuffle = 1;

nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo(ncfile,'z');

if v.Shuffle ~= 1
	error('2D shuffle test failed');
end

if v.Deflate ~= 0
	error('2D deflate test failed');
end















%--------------------------------------------------------------------------
function test_2d_deflate (ncfile)


nc_create_empty (ncfile,nc_netcdf4_classic);
nc_adddim ( ncfile, 'x', 500 );
nc_adddim ( ncfile, 'y', 100 );

clear varstruct;
varstruct.Name = 'z';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'y', 'x' };
varstruct.Deflate = 1;

nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo(ncfile,'z');

if v.Shuffle ~= 0
	error('2D shuffle test failed');
end

if v.Deflate ~= 1
	error('2D deflate test failed');
end




clear varstruct;
varstruct.Name = 'z2';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'y', 'x' };
varstruct.Deflate = 5;

nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo(ncfile,'z2');

if v.Shuffle ~= 0
	error('2D shuffle test failed');
end

if v.Deflate ~= 5
	error('2D deflate test failed');
end











%--------------------------------------------------------------------------
function test_2d_chunking_shuffle_deflate (ncfile)


nc_create_empty (ncfile,nc_netcdf4_classic);
nc_adddim ( ncfile, 'x', 500 );
nc_adddim ( ncfile, 'y', 100 );

clear varstruct;
varstruct.Name = 'z';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'y', 'x' };
varstruct.Chunking = [10 50];
varstruct.Shuffle = 1;
varstruct.Deflate = 9;

nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo(ncfile,'z');

if (v.Chunking(1) ~= 10) || (v.Chunking(2) ~= 50)
	error('2D chunking size test failed');
end


if v.Shuffle ~= 1
	error('2D shuffle test failed');
end

if v.Deflate ~= 9
	error('2D deflate test failed');
end
















%--------------------------------------------------------------------------
function test_no_inputs()

try
    nc_addvar;
catch %#ok<CTCH>
	return
end
error ( '%s:  succeeded when it should have failed.\n', mfilename );












%--------------------------------------------------------------------------
function test_too_many_inputs (ncfile,mode)

nc_create_empty (ncfile,mode);
clear varstruct;
varstruct.Name = 'test_var';
try
    nc_addvar ( ncfile, varstruct, 5 );
catch %#ok<CTCH>
	return
end
error ( '%s:  succeeded when it should have failed.\n', mfilename );
















%--------------------------------------------------------------------------
function test_2nd_input_not_char (ncfile,mode)
% test 4:  2nd input not character
nc_create_empty (ncfile,mode);

try
    nc_addvar ( ncfile, 5 );
catch %#ok<CTCH>
	return
end
error ( 'succeeded when it should have failed.');













%--------------------------------------------------------------------------
function test_empty_struct (ncfile,mode)
% test 5:  No name provided in varstruct
nc_create_empty (ncfile,mode);
clear varstruct;
varstruct = struct([]);
try
    nc_addvar ( ncfile, varstruct );
catch %#ok<CTCH>
	return
end
error ( 'succeeded when it should have failed.' );










%--------------------------------------------------------------------------
function test_singletons (ncfile,mode)

nc_create_empty (ncfile,mode);
clear varstruct;
varstruct.Name = 'x';
varstruct.Datatype = 'double';
nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo ( ncfile, 'x' );
if ~strcmp(v.Datatype,'double')
    error ( '%s:  data type was wrong.\n', mfilename );
end
if ( v.Size ~= 1 ) 
    error ( '%s:  data size was wrong.\n', mfilename );
end
if ( ~isempty(v.Dimension) ) 
    error ( '%s:  dimensions were wrong.\n', mfilename );
end


clear varstruct;
varstruct.Name = 'x2';
varstruct.Datatype = 'float';
nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo ( ncfile, 'x2' );
if ~strcmp(v.Datatype,'single')
    error ( 'failed' );
end

varstruct.Name = 'x3';
varstruct.Datatype = 'int';
nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo ( ncfile, 'x3' );
if ~strcmp(v.Datatype,'int32')
    error ( '%s:  data type was wrong.\n', mfilename );
end

clear varstruct;
varstruct.Name = 'x4';
varstruct.Datatype = 'short';
nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo ( ncfile, 'x4' );
if ~strcmp(v.Datatype,'int16')
    error ( '%s:  data type was wrong.\n', mfilename );
end

clear varstruct;
varstruct.Name = 'x5';
varstruct.Datatype = 'byte';
nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo ( ncfile, 'x5' );
if ~strcmp(v.Datatype,'int8')
    error ( '%s:  data type was wrong.\n', mfilename );
end

clear varstruct;
varstruct.Name = 'x6';
varstruct.Datatype = 'char';
nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo ( ncfile, 'x6' );
if ~strcmp(v.Datatype,'char')
    error ( '%s:  data type was wrong.\n', mfilename );
end

return







%--------------------------------------------------------------------------
function test_fixed_dimension (ncfile,mode)

% test 12:  Add a variable with a named fixed dimension.
nc_create_empty (ncfile,mode);
if strcmp(mode,'hdf4')
    nc_adddim(ncfile,'x',5);
else
    nc_adddim ( ncfile, 'x', 5 );
end
clear varstruct;
varstruct.Name = 'y';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'x' };
nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo ( ncfile, 'y' );
if ~strcmp(v.Datatype,'double')
    error ( '%s:  data type was wrong.\n', mfilename );
end
if any(v.Size - 5)
    error ( '%s:  variable size was wrong.\n', mfilename );
end
if ( length(v.Dimension) ~= 1 ) 
    error ( '%s:  dimensions were wrong.\n', mfilename );
end
if ( ~strcmp(v.Dimension{1}, 'x' ) ) 
    error ( '%s:  dimensions were wrong.\n', mfilename );
end

return










%--------------------------------------------------------------------------
function test_unlimited(ncfile,mode)

% test 13:  Add a variable with a named unlimited dimension.
nc_create_empty (ncfile,mode);
nc_adddim ( ncfile, 'x', 0 );
clear varstruct;
varstruct.Name = 'y';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'x' };
nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo ( ncfile, 'y' );
if ~strcmp(v.Datatype,'double')
    error ( 'failed' );
end
if (v.Size ~= 0)
    error ( 'failed' );
end
if ( ~v.Unlimited)
    error ( 'failed' );
end

return












%--------------------------------------------------------------------------
function test_unlimited_plus_fixed (ncfile,mode)
% test 14:  Add a variable with a named unlimited dimension and named fixed dimension.
nc_create_empty (ncfile,mode);
nc_adddim ( ncfile, 'x', 0 );
nc_adddim(ncfile,'y',5);

clear varstruct;
varstruct.Name = 'z';
varstruct.Datatype = 'double';

if getpref('SNCTOOLS','PRESERVE_FVD',false)
    varstruct.Dimension = { 'y', 'x' };
else
    varstruct.Dimension = { 'x', 'y' };
end

nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo ( ncfile, 'z' );
if ~strcmp(v.Datatype,'double')
    error('failed')
end

if getpref('SNCTOOLS','PRESERVE_FVD',false)
    if (v.Size(2) ~= 0) && (v.Size(1) ~= 5 )
        error ( '%s:  %s:  variable size was wrong.\n', mfilename, testid );
    end
else
    if (v.Size(1) ~= 0) && (v.Size(2) ~= 5 )
        error ( '%s:  %s:  variable size was wrong.\n', mfilename, testid );
    end
end

if ( ~v.Unlimited )
    error ( '%s:  %s:  unlimited classifaction was wrong.\n', mfilename, testid );
end

return









%--------------------------------------------------------------------------
function test_with_attributes (ncfile,mode)
% test 15:  Add a variable with attribute structures.
nc_create_empty (ncfile,mode);
nc_adddim ( ncfile, 'x', 0 );
nc_adddim(ncfile,'y',5);
clear varstruct;
varstruct.Name = 'z';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'x' };
varstruct.Attribute(1).Name = 'test';
varstruct.Attribute(1).Value = 'blah';
nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo ( ncfile, 'z' );
if ~strcmp(v.Datatype,'double')
    error ( 'failed');
end
if (v.Size(1) ~= 0) && (v.Size(2) ~= 5 )
    error ( '%s:  variable size was wrong.\n', mfilename );
end
if ( ~v.Unlimited)
    error ( '%s:  unlimited classifaction was wrong.\n', mfilename );
end
if ( length(v.Attribute) ~= 1)
    error ( '%s:  number of attributes was wrong.\n', mfilename );
end

return









%--------------------------------------------------------------------------
function test_numeric_nctype (ncfile,mode)

% test 17:  Add a variable with a numeric Datatype
nc_create_empty (ncfile,mode);
nc_adddim ( ncfile, 'x', 5 );
clear varstruct;
varstruct.Name = 'x';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'x' };
nc_addvar ( ncfile, varstruct );

v = nc_getvarinfo ( ncfile, 'x' );
if ~strcmp(v.Datatype,'double')
    error ( 'failed')
end
if any(v.Size - 5)
    error ( '%s:  variable size was wrong.\n', mfilename );
end
if ( length(v.Dimension) ~= 1 ) 
    error ( '%s:  dimensions were wrong.\n', mfilename );
end
if ( ~strcmp(v.Dimension{1}, 'x' ) ) 
    error ( '%s:  dimensions were wrong.\n', mfilename );
end




return












%--------------------------------------------------------------------------
function test_var_already_there (ncfile,mode)


nc_create_empty (ncfile,mode);
nc_adddim ( ncfile, 'x', 5 );

clear varstruct;
varstruct.Name = 'x';
varstruct.Datatype = 'double';
varstruct.Dimension = { 'x' };
nc_addvar ( ncfile, varstruct );
try
    nc_addvar ( ncfile, varstruct );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed');




%--------------------------------------------------------------------------
function test_illegal_field_name (ncfile,mode)
% Should produce a warning, which we want to suppress.

warning('off','SNCTOOLS:nc_addvar:unrecognizedFieldName');
nc_create_empty (ncfile,mode);
nc_adddim ( ncfile, 'x', 5 );

clear varstruct;
varstruct.Name = 'x';
varstruct.nnccttyyppee = { 'x' };
varstruct.Dimension = { 'x' };
nc_addvar ( ncfile, varstruct );

warning('on','SNCTOOLS:nc_addvar:unrecognizedFieldName');



