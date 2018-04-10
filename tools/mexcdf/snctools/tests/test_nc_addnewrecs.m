function test_nc_addnewrecs ( ncfile )
% TEST_NC_ADDNEWRECS
%
% Relies on nc_addvar, nc_getvarinfo
%
% Test run include
%    No inputs, should fail.
%    One inputs, should fail.
%    3.  Two inputs, 2nd is not a structure, should fail.
%    4.  Two inputs, 2nd is an empty structure, should fail.
%    5.  Two inputs, 2nd is a structure with bad variable names, should fail.
%    6.  Three inputs, 3rd is non existant unlimited dimension.
%    7.  Two inputs, write to two variables, should succeed.
%    8.  Two inputs, write to two variables, one of them not unlimited, should fail.
%    9.  Try to write to a file with no unlimited dimension.
%   10.  Do two successive writes.  Should succeed.
%   11.  Do two successive writes, but on the 2nd write let the coordinate
%        variable overlap with the previous write.  Should still succeed,
%        but fewer datums will be written out.
%   12.  Do two successive writes, but with the same data.  Should 
%        return an empty buffer, but not fail
% Test 13:  Add a single record.  This is a corner case.
% Test 14:  Add a single record, trailing singleton dimensions.

fprintf('Testing NC_ADDNEWRECS ...\n' );

if nargin == 0
	ncfile = 'foo.nc';
end

run_tests_nc3(ncfile);
run_hdf4_tests;
run_tests_nc4(ncfile);

fprintf('OK\n');

%--------------------------------------------------------------------------
function run_hdf4_tests()
hfile = 'foo.hdf';
create_ncfile(hfile,'hdf4');
run_all_tests(hfile,'hdf4');

%-------------------------------------------------------------------------------
function run_tests_nc3 ( ncfile)
fprintf('\tTesting netcdf-3...  ');
create_ncfile ( ncfile )
run_all_tests(ncfile,nc_clobber_mode);
fprintf('OK\n');

%-------------------------------------------------------------------------------
function run_tests_nc4 ( ncfile)
if ~netcdf4_capable
	fprintf('\tmexnc (netcdf-4) backend testing filtered out on configurations where the library version < 4.\n');
	return
end

fprintf('\tTesting netcdf-4...  ');
create_ncfile ( ncfile, nc_netcdf4_classic )
run_all_tests(ncfile,nc_netcdf4_classic);
fprintf('OK\n');

%-------------------------------------------------------------------------------
function run_all_tests(ncfile,mode)

test_no_inputs;
test_only_one_input ( ncfile );
test_003 ( ncfile );
test_004 ( ncfile );
test_005 ( ncfile );
test_006 ( ncfile );
test_two_inputs ( ncfile );
test_008 ( ncfile );

% test_009 makes a new file

test_009 ( ncfile, mode );
test_010 ( ncfile, mode );
test_011 ( ncfile );

test_012(ncfile,mode);
test_013(ncfile,mode)
test_014(ncfile,mode);


return








%-------------------------------------------------------------------------------
function create_ncfile ( ncfile, mode )

if nargin > 1
    if ischar(mode) && strcmp(mode,'hdf4')
        create_ncfile_hdf4(ncfile);
    else
        create_ncfile_mexnc(ncfile,mode);
    end
else

	switch ( version('-release') )
	    case { '14', '2006a', '2006', '2007a', '2007b', '2008a' }
			create_ncfile_mexnc(ncfile,nc_clobber_mode);
		otherwise
			create_ncfile_tmw(ncfile,nc_clobber_mode);
	end
end


% Add a variable along the time dimension
varstruct.Name = 'test_var';
varstruct.Nctype = 'float';
varstruct.Dimension = { 'time' };
varstruct.Attribute(1).Name = 'long_name';
varstruct.Attribute(1).Value = 'This is a test';
varstruct.Attribute(2).Name = 'short_val';
varstruct.Attribute(2).Value = int16(5);

nc_addvar ( ncfile, varstruct );


clear varstruct;
varstruct.Name = 'test_var2';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'time' };

nc_addvar ( ncfile, varstruct );


clear varstruct;
varstruct.Name = 'trailing_singleton';
varstruct.Nctype = 'double';
if getpref('SNCTOOLS','PRESERVE_FVD',false)
    varstruct.Dimension = { 'y', 'z', 'time' };
else
    varstruct.Dimension = { 'time', 'z', 'y' };
end

nc_addvar ( ncfile, varstruct );


% Don't do this if HDF4.  We already have the coordinate variable there.
if ~((nargin == 2) && ischar(mode) && strcmp(mode,'hdf4'))
    clear varstruct;
    varstruct.Name = 'time';
    varstruct.Nctype = 'double';
    varstruct.Dimension = { 'time' };
    
    nc_addvar ( ncfile, varstruct );
end


clear varstruct;
varstruct.Name = 'test_var3';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };

nc_addvar ( ncfile, varstruct );

return









%--------------------------------------------------------------------------
function create_ncfile_mexnc(ncfile, mode )
    %
    % ok, first create this baby.
    [ncid, status] = mexnc ( 'create', ncfile, mode );
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        error ( ncerr_msg );
    end
    
    
    %
    % Create a fixed dimension.  
    len_x = 4;
    [dud, status] = mexnc ( 'def_dim', ncid, 'x', len_x ); %#ok<ASGLU>
    if ( status ~= 0 )
        error ( mexnc('strerror',status) );
    end
    
    %
    % Create two singleton dimensions.
    [ydimid, status] = mexnc ( 'def_dim', ncid, 'y', 1 ); %#ok<ASGLU>
    if ( status ~= 0 )
        error ( mexnc('strerror',status) );
    end
    
    [zdimid, status] = mexnc ( 'def_dim', ncid, 'z', 1 ); %#ok<ASGLU>
    if ( status ~= 0 )
        error ( mexnc('strerror',status) );
    end
    
    
    
    len_t = 0;
    [tdimid, status] = mexnc ( 'def_dim', ncid, 'time', len_t ); %#ok<ASGLU>
    if ( status ~= 0 )
        error ( mexnc('strerror',status) );
    end
    
    %
    % CLOSE
    status = mexnc ( 'close', ncid );
    if ( status ~= 0 )
        error ( 'CLOSE failed' );
    end
    
%--------------------------------------------------------------------------
function create_ncfile_hdf4(hfile)
    
nc_create_empty(hfile,'hdf4');
nc_adddim(hfile,'x',4);
nc_adddim(hfile,'y',1);
nc_adddim(hfile,'z',1);
nc_adddim(hfile,'time',0);



%-------------------------------------------------------------------------------
function create_ncfile_tmw(ncfile, mode )
    ncid= netcdf.create(ncfile, mode );
    
    %
    % Create a fixed dimension.  
    len_x = 4;
    netcdf.defDim ( ncid, 'x', len_x );
    
    %
    % Create two singleton dimensions.
    netcdf.defDim(ncid, 'y', 1 );
    netcdf.defDim(ncid, 'z', 1 );
    
    
    len_t = 0;
    netcdf.defDim(ncid, 'time', len_t );
    
    netcdf.close( ncid );


%---------------------------------------------------------------------------
function test_no_inputs (  )

%
% Try no inputs
try
    nc_addnewrecs;
catch %#ok<CTCH>
	return
end
error('test failure');







%---------------------------------------------------------------------------
function test_only_one_input ( ncfile )

%
% Try one inputs
try
    nc_addnewrecs ( ncfile );
catch %#ok<CTCH>
	return
end

error('test failure');











%---------------------------------------------------------------------------
function test_003 ( ncfile )

%
% Try with 2nd input that isn't a structure.
nc_addnewrecs ( ncfile, [] );












%---------------------------------------------------------------------------
function test_004 ( ncfile )

%
% Try with 2nd input that is an empty structure.
nc_addnewrecs ( ncfile, struct([]) );











%---------------------------------------------------------------------------
function test_005 ( ncfile )

%
% Try a structure with bad names
input_data.a = [3 4];
input_data.b = [5 6];
try
    nc_addnewrecs ( ncfile, input_data );
catch %#ok<CTCH>
	return
end

error('test failure');











%---------------------------------------------------------------------------
function test_006 ( ncfile )

%
% Try good data with a bad record variable name
input_data.test_var = [3 4]';
input_data.test_var2 = [5 6]';
try
    nc_addnewrecs ( ncfile, input_data, 'bad_time' );
catch %#ok<CTCH>
    return
end
error('nc_addnewrecs succeeded with a badly named record variable, should have failed');










%---------------------------------------------------------------------------
function test_two_inputs ( ncfile )

%
% Try a good test.
before = nc_getvarinfo ( ncfile, 'test_var2' );


clear input_buffer;
input_buffer.test_var = single([3 4 5]');
input_buffer.test_var2 = [3 4 5]';
input_buffer.time = [1 2 3]';

nc_addnewrecs ( ncfile, input_buffer );

after = nc_getvarinfo ( ncfile, 'test_var2' );
if ( (after.Size - before.Size) ~= 3 )
    error ( '%s:  nc_addnewrecs failed to add the right number of records.', mfilename );
end
return











%---------------------------------------------------------------------------
function test_008 ( ncfile )

%
% Try writing to a fixed size variable


input_buffer.test_var = single([3 4 5]');
input_buffer.test_var2 = [3 4 5]';
input_buffer.test_var3 = [3 4 5]';

try
    nc_addnewrecs ( ncfile, input_buffer );
catch %#ok<CTCH>
    return
end
error('nc_addnewrecs succeeded on writing to a fixed size variable, should have failed.');













%---------------------------------------------------------------------------
function test_009(ncfile,mode)


if strcmp(mode,'hdf4')

	nc_create_empty(ncfile,'hdf4');
	nc_adddim(ncfile,'x',4);

elseif snctools_use_tmw
    ncid = netcdf.create(ncfile, nc_clobber_mode );
    len_x = 4;
    netcdf.defDim(ncid, 'x', len_x );
    netcdf.close(ncid );
else
    %
    % ok, first create this baby.
    [ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        error(ncerr_msg);
    end
    
    
    %
    % Create a fixed dimension.  
    len_x = 4;
    [xdimid, status] = mexnc ( 'def_dim', ncid, 'x', len_x ); %#ok<ASGLU>
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        error(ncerr_msg);
    end
    
    
    %
    % CLOSE
    status = mexnc ( 'close', ncid );
    if ( status ~= 0 )
        error ( 'CLOSE failed' );
    end
end

clear varstruct;
varstruct.Name = 'test_var3';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };

nc_addvar ( ncfile, varstruct );


input_buffer.time = [1 2 3]';
try
    nc_addnewrecs ( ncfile, input_buffer );
catch %#ok<CTCH>
    return
end

error('nc_addnewrecs passed when writing to a file with no unlimited dimension');












%---------------------------------------------------------------------------
function test_010(ncfile,mode)

if ischar(mode) && strcmp(mode,'hdf4')
	nc_create_empty(ncfile,'hdf4');
	nc_adddim(ncfile,'x',4);
	nc_adddim(ncfile,'time',0);
elseif snctools_use_tmw
    ncid = netcdf.create(ncfile, nc_clobber_mode );
    len_x = 4;
    netcdf.defDim(ncid, 'x', len_x );
    netcdf.defDim(ncid, 'time', 0 );
    netcdf.close(ncid );

	clear varstruct;
	varstruct.Name = 'time';
	varstruct.Nctype = 'double';
	varstruct.Dimension = { 'time' };
	nc_addvar ( ncfile, varstruct );

else
    %
    % ok, first create this baby.
    [ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        error(ncerr_msg);
    end
    
    
    %
    % Create a fixed dimension.  
    len_x = 4;
    mexnc ( 'def_dim', ncid, 'x', len_x );
    mexnc ( 'def_dim', ncid, 'time', 0 );
    status = mexnc ( 'close', ncid );
    if ( status ~= 0 )
        error ( 'CLOSE failed' );
    end

	clear varstruct;
	varstruct.Name = 'time';
	varstruct.Nctype = 'double';
	varstruct.Dimension = { 'time' };
	nc_addvar ( ncfile, varstruct );

end





before = nc_getvarinfo ( ncfile, 'time' );

clear input_buffer;
input_buffer.time = [1 2 3]';


nc_addnewrecs ( ncfile, input_buffer );
input_buffer.time = [4 5 6]';
nc_addnewrecs ( ncfile, input_buffer );

after = nc_getvarinfo ( ncfile, 'time' );
if ( (after.Size - before.Size) ~= 6 )
    error ( '%s:  nc_addnewrecs failed to add the right number of records.', mfilename );
end

return








%---------------------------------------------------------------------------
function test_011 ( ncfile )

if snctools_use_tmw
    ncid = netcdf.create(ncfile, nc_clobber_mode );
    len_x = 4;
    netcdf.defDim(ncid, 'x', len_x );
    netcdf.defDim(ncid, 'time', 0 );
    netcdf.close(ncid );
else
    
    %
    % ok, first create this baby.
    ncid = mexnc ( 'create', ncfile, nc_clobber_mode );

    
    
    %
    % Create a fixed dimension.  
    len_x = 4;
    mexnc ( 'def_dim', ncid, 'x', len_x );

    
    
    len_t = 0;
    mexnc ( 'def_dim', ncid, 'time', len_t );
    status = mexnc ( 'close', ncid );
    if ( status ~= 0 )
        error ( 'CLOSE failed' );
    end
end

clear varstruct;
varstruct.Name = 'time';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'time' };
nc_addvar ( ncfile, varstruct );




before = nc_getvarinfo ( ncfile, 'time' );

clear input_buffer;
input_buffer.time = [1 2 3]';


nc_addnewrecs ( ncfile, input_buffer );
input_buffer.time = [3 4 5]';
nc_addnewrecs ( ncfile, input_buffer );

after = nc_getvarinfo ( ncfile, 'time' );
if ( (after.Size - before.Size) ~= 5 )
    error ( '%s:  nc_addnewrecs failed to add the right number of records.', mfilename );
end
return














%---------------------------------------------------------------------------
function create_test012_file(ncfile,mode)

nc_create_empty(ncfile,mode);

% baseline case
nc_add_dimension ( ncfile, 'ocean_time', 0 );

if ischar(mode) && strcmp(mode,'hdf4')
    % We already have the ocean_time coordinate variable in hdf4 case.
else
    
    clear varstruct;
    varstruct.Name = 'ocean_time';
    varstruct.Nctype = 'double';
    varstruct.Dimension = { 'ocean_time' };
    nc_addvar ( ncfile, varstruct );
end

clear varstruct;
varstruct.Name = 't1';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 't2';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 't3';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

%---------------------------------------------------------------------------
function test_012(ncfile,mode)

create_test012_file(ncfile,mode);
%
% write ten records
x = (0:9)';
b.ocean_time = x;
b.t1 = x;
b.t2 = 1./(1+x);
b.t3 = x.^2;
nc_addnewrecs ( ncfile, b, 'ocean_time' );
nb = nc_addnewrecs ( ncfile, b, 'ocean_time' );
if ( ~isempty(nb) )
    error ( 'nc_addnewrecs failed on %s.\n', ncfile );
end
v = nc_getvarinfo ( ncfile, 't1' );
if ( v.Size ~= 10 )
    error ( '%s:  expected var length was not 10.\n', mfilename );
end

return








%--------------------------------------------------------------------------
function create_013_testfile(ncfile,mode)
nc_create_empty(ncfile,mode);

nc_add_dimension ( ncfile, 'time', 0 );
nc_add_dimension ( ncfile, 'x', 10 );
nc_add_dimension ( ncfile, 'y', 10 );
nc_add_dimension ( ncfile, 'z', 10 );

if ischar(mode) && strcmp(mode,'hdf4')
    % no need to add time var here
else
    clear varstruct;
    varstruct.Name = 'time';
    varstruct.Nctype = 'double';
    varstruct.Dimension = { 'time' };
    nc_addvar ( ncfile, varstruct );
end

clear varstruct;
varstruct.Name = 't1';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'time' };
nc_addvar ( ncfile, varstruct );


clear varstruct;
varstruct.Name = 't2';
varstruct.Nctype = 'double';
if getpref('SNCTOOLS','PRESERVE_FVD')
    varstruct.Dimension = { 'x','y', 'time' };
else
    varstruct.Dimension = { 'time', 'y', 'x' };
end
nc_addvar ( ncfile, varstruct );


clear varstruct;
varstruct.Name = 't3';
varstruct.Nctype = 'double';
if getpref('SNCTOOLS','PRESERVE_FVD')
    varstruct.Dimension = { 'y', 'time' };
else
    varstruct.Dimension = { 'time', 'y'};
end
nc_addvar ( ncfile, varstruct );


clear varstruct;
varstruct.Name = 't4';
varstruct.Nctype = 'double';
if getpref('SNCTOOLS','PRESERVE_FVD')
    varstruct.Dimension = { 'x', 'y', 'z', 'time' };
else
    varstruct.Dimension = { 'time', 'z', 'y', 'x'};
end
nc_addvar ( ncfile, varstruct );


%---------------------------------------------------------------------------
function test_013(ncfile,mode)

create_013_testfile(ncfile,mode);


if getpref('SNCTOOLS','PRESERVE_FVD')
    b.time = 0;
    b.t1 = 0;
    b.t2 = zeros(10,10);
    b.t3 = zeros(10,1);
    b.t4 = zeros(10,10,10);
else
    b.time = 0;
    b.t1 = 0;
    b.t2 = zeros(10,10);
    b.t3 = zeros(1,10);
    b.t4 = zeros(10,10,10);
end

nc_addnewrecs ( ncfile, b, 'time' );

clear b
if getpref('SNCTOOLS','PRESERVE_FVD')
    b.time = 1;
    b.t1 = 1;
    b.t2 = ones(10,10);
    b.t3 = ones(10,1);
    b.t4 = ones(10,10,10);
else
    b.time = 1;
    b.t1 = 1;
    b.t2 = ones(10,10);
    b.t3 = ones(1,10);
    b.t4 = ones(10,10,10);
end
nc_addnewrecs ( ncfile, b, 'time' );


%
% Now read them back.  
b = nc_getbuffer ( ncfile, 0, 2 );
if length(b.time) ~= 2
    error('length of time variable was %d and not the expected 2\n', length(b.time) );
end
if (b.time(1) ~= 0) && (b.time(2) ~= 1)
    error('values of time variable are wrong');
end


return







%--------------------------------------------------------------------------
function create_014_testfile(ncfile,mode)

nc_create_empty(ncfile,mode);

nc_add_dimension ( ncfile, 'time', 0 );
nc_add_dimension ( ncfile, 'x', 1 );
nc_add_dimension ( ncfile, 'y', 1 );

if ischar(mode) && strcmp(mode,'hdf4')
    % no need to add time var here
else
    
    clear varstruct;
    varstruct.Name = 'time';
    varstruct.Nctype = 'double';
    varstruct.Dimension = { 'time' };
    nc_addvar ( ncfile, varstruct );
end

clear varstruct;
varstruct.Name = 't1';
varstruct.Nctype = 'double';
if getpref('SNCTOOLS','PRESERVE_FVD')
    varstruct.Dimension = { 'x', 'y', 'time' };
else
    varstruct.Dimension = { 'time', 'y', 'x' };
end
nc_addvar ( ncfile, varstruct );

%---------------------------------------------------------------------------
function test_014(ncfile,mode)

create_014_testfile(ncfile,mode);

b.time = 0;
b.t1 = 0;

nc_addnewrecs ( ncfile, b, 'time' );

clear b
b.time = 1;
b.t1 = 1;
nc_addnewrecs ( ncfile, b, 'time' );


%
% Now read them back.  
t1 = nc_varget ( ncfile, 't1' );
if (t1(1) ~= 0) && (t1(2) ~= 1)
    error('values are wrong');
end


return
