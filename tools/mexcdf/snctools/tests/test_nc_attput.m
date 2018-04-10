function test_nc_attput ( ncfile )
% TEST_NC_ATTPUT
%
% Tests run include
%
% write/retrieve a new double attribute
% write/retrieve a new float attribute
% write/retrieve a new int attribute
% write/retrieve a new short int attribute
% write/retrieve a new uint8 attribute
% write/retrieve a new int8 attribute
% write/retrieve a new text attribute
%
% These are run for both netcdf-3 and netcdf-4

fprintf ( 1, 'Testing NC_ATTGET, NC_ATTPUT...\n' );


if nargin == 0
	ncfile = 'foo.nc';
end

test_classic(ncfile);
test_hdf4('foo.hdf');
test_netcdf4(ncfile);

fprintf('OK\n');
return;


%--------------------------------------------------------------------------
function test_classic(ncfile)
fprintf('\tRunning netcdf-3 tests...  ');
nc_create_empty(ncfile);
run_tests(ncfile);
fprintf('OK\n');
return

%--------------------------------------------------------------------------
function test_hdf4(ncfile)
fprintf('\tRunning hdf4 tests...  ');
nc_create_empty(ncfile,'hdf4');
run_tests(ncfile);

% HDF4 specific tests
test_hdf4_datastrs;
test_hdf4_cal;
test_hdf4_fillvalue;
fprintf('OK\n');
return
%--------------------------------------------------------------------------
function test_netcdf4(ncfile)
if ~netcdf4_capable
	fprintf('\tmexnc (netcdf-4) backend testing filtered out on ');
    fprintf('configurations where the library version < 4.\n');
	return
end

fprintf('\tRunning netcdf-4 tests...  ');
nc_create_empty(ncfile,nc_netcdf4_classic);
run_tests(ncfile);
verify_netcdf4(ncfile);
fprintf('OK\n');
return


%--------------------------------------------------------------------------
function run_tests(ncfile)

test_read_write_double_att ( ncfile );
test_read_write_float_att ( ncfile );
test_read_write_int_att ( ncfile );
test_read_write_short_att ( ncfile );
test_read_write_uint8_att ( ncfile );
test_read_write_int8_att ( ncfile );
test_read_write_char_att ( ncfile );
test_read_write_empty_att(ncfile);

return




%--------------------------------------------------------------------------
function test_read_write_empty_att(ncfile )
% BACKGROUND:  in R2008b, the TMW mex-file incorrectly disallowed empty 
% attributes, which are most definitely allowed. 
%
% REFERENCE:  http://www.mathworks.com/support/bugreports/609383


info = nc_info(ncfile);
if strcmp(info.Format,'HDF4')
    return
end

warning('off','SNCTOOLS:NCATTPUT:emptyAttributeBug');
nc_attput ( ncfile, nc_global, 'emptyAtt', '' );
x = nc_attget ( ncfile, nc_global, 'emptyAtt' );

if ( ~ischar(x) )
    error('class of retrieved attribute was not char.' );
end



v = version('-release');
switch(v)
case { '2008b','2009a','2009b'}
    if ( numel(x) ~= 1 )
        error ( 'retrieved attribute was not one char in length' );
    end
    %%% If you have applied the fix for bug #609383, then
    %%% comment out the code above and uncomment the
	%%% code below.
    %%% if ( numel(x) ~= 0 )
    %%%     error ( 'retrieved attribute was not empty' );
    %%% end
otherwise
    if ( numel(x) ~= 0 )
        error ( 'retrieved attribute was not empty' );
    end
end

warning('on','SNCTOOLS:NCATTPUT:emptyAttributeBug');
return



%--------------------------------------------------------------------------
function test_read_write_double_att ( ncfile )

nc_attput ( ncfile, nc_global, 'new_att', 0 );
x = nc_attget ( ncfile, nc_global, 'new_att' );

if ( ~strcmp(class(x), 'double' ) )
	error('class of retrieved attribute was not double.' );
end

if ( double(x) ~= 0 )
	error ( 'retrieved attribute was not same as written value' );
end

return




%--------------------------------------------------------------------------
function test_read_write_float_att ( ncfile )

nc_attput ( ncfile, nc_global, 'new_att2', single(0) );
x = nc_attget ( ncfile, nc_global, 'new_att2' );

if ( ~strcmp(class(x), 'single' ) )
	error('%class of retrieved attribute was not single.');
end
if ( double(x) ~= 0 )
	error ( 'retrieved attribute was not same as written value' );
end


%--------------------------------------------------------------------------
function test_read_write_int_att ( ncfile )

nc_attput ( ncfile, nc_global, 'new_att3', int32(0) );
x = nc_attget ( ncfile, nc_global, 'new_att3' );

if ( ~strcmp(class(x), 'int32' ) )
	error('class of retrieved attribute was not int32.');
end
if ( double(x) ~= 0 )
	error ( 'retrieved attribute was not same as written value' );
end


%--------------------------------------------------------------------------
function test_read_write_short_att ( ncfile )

nc_attput ( ncfile, nc_global, 'new_att4', int16(0) );
x = nc_attget ( ncfile, nc_global, 'new_att4' );

if ( ~strcmp(class(x), 'int16' ) )
	error('class of retrieved attribute was not int16.');
end
if ( double(x) ~= 0 )
	error ( 'retrieved attribute was not same as written value' );
end


%--------------------------------------------------------------------------
function test_read_write_uint8_att ( ncfile )

nc_attput ( ncfile, nc_global, 'new_att5', uint8(0) );
x = nc_attget ( ncfile, nc_global, 'new_att5' );

info = nc_info(ncfile);
if strcmp(info.Format,'HDF4')
    if ~strcmp(class(x), 'uint8' )
        error('class of retrieved attribute was not uint8.' );
    end
elseif  ~strcmp(class(x), 'int8' )
    error('class of retrieved attribute was not int8.' );
end
if ( double(x) ~= 0 )
	error ( 'retrieved attribute was not same as written value' );
end


%--------------------------------------------------------------------------
function test_read_write_int8_att ( ncfile )

nc_attput ( ncfile, nc_global, 'new_att6', int8(0));
x = nc_attget ( ncfile, nc_global, 'new_att6' );

if  ~strcmp(class(x), 'int8' )
    error('class of retrieved attribute was not int8.' );
end

if ( double(x) ~= 0 )
	error ( 'retrieved attribute was not same as written value' );
end


%--------------------------------------------------------------------------
function test_read_write_char_att ( ncfile )

nc_attput ( ncfile, nc_global, 'new_att7', '0' );
x = nc_attget ( ncfile, nc_global, 'new_att7' );

if ( ~ischar(x ) )
	error('class of retrieved attribute was not char.');
end
if (x ~= '0' )
	error ( 'retrieved attribute was not same as written value' );
end


return


%--------------------------------------------------------------------------
function test_hdf4_datastrs (  )

nc_create_empty('foo.hdf','hdf4');
nc_adddim('foo.hdf','x', 4);
nc_attput('foo.hdf','x','coordsys','dud');
x = nc_attget('foo.hdf','x','coordsys');

if ( ~ischar(x ) )
	error('class of retrieved attribute was not char.');
end
if ~strcmp(x,'dud')
	error ( 'retrieved attribute was not same as written value' );
end


return

%--------------------------------------------------------------------------
function test_hdf4_cal (  )

nc_create_empty('foo.hdf','hdf4');
nc_adddim('foo.hdf','x', 4);
nc_attput('foo.hdf','x','scale_factor',1);
x = nc_attget('foo.hdf','x','scale_factor');
y = nc_attget('foo.hdf','x','add_offset');

if (x ~= 1) || (y ~= 0)
	error ( 'retrieved attribute was not same as written value' );
end


return

%--------------------------------------------------------------------------
function test_hdf4_fillvalue (  )

nc_create_empty('foo.hdf','hdf4');
nc_adddim('foo.hdf','x',4); 
nc_attput('foo.hdf','x','_FillValue',99);
x = nc_attget('foo.hdf','x','_FillValue');


if (x ~= 99)
	error ( 'retrieved attribute was not same as written value' );
end


return

