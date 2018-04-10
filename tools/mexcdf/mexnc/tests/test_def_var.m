function test_def_var ( ncfile )
% TEST_DEF_VAR
%
% Test 1:  Create a double var
% Test 2:  Create a float var
% Test 3:  Create an int32 var
% Test 4:  Create an int16 var
% Test 5:  Create a byte var
% Test 6:  Create a char var
% Test 7:  Bad ncid.
% Test 8:  Empty name.
% Test 9:  Bogus datatype.
% Test 10:  Bad number of dimensions.
% Test 11:  Bogus dimid.
% Test 12:  ncid is not numeric
% Test 13:  varname is not character
% Test 14:  datatype is not character or numeric
% Test 15:  ndims is not numeric
% Test 16:  dimids is not numeric
% Test 17:  try to pass too many dimensions

if nargin<1
	ncfile = 'foo.nc';
end

error_condition = 0;

[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


%
% DIMDEF
[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', 20 );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

% 
% Test 1:  Create a double var
testid = 'Test 1';
[xdvarid, status] = mexnc ( 'def_var', ncid, 'x_double', nc_double, 1, xdimid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

% 
% Test 2:  Create a float var
testid = 'Test 2';
[xdvarid, status] = mexnc ( 'def_var', ncid, 'x_float', nc_float, 1, xdimid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

% 
% Test 3:  Create an int32 var
testid = 'Test 3';
[xdvarid, status] = mexnc ( 'def_var', ncid, 'x_int32', nc_int, 1, xdimid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

% 
% Test 4:  Create an int16 var
testid = 'Test 4';
[xdvarid, status] = mexnc ( 'def_var', ncid, 'x_int16', nc_short, 1, xdimid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

% 
% Test 5:  Create a byte var
testid = 'Test 5';
[xdvarid, status] = mexnc ( 'def_var', ncid, 'x_byte', nc_byte, 1, xdimid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

% 
% Test 6:  Create a char var
testid = 'Test 6';
[xdvarid, status] = mexnc ( 'def_var', ncid, 'x_char', nc_char, 1, xdimid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

%
% Test 7:  Bad ncid.
testid = 'Test 7';
[test_dimid, status] = mexnc ( 'def_var', -2, 'x_double', nc_double, 1, xdimid );
if ( status == 0 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid );
	error ( err_msg );
end


% Test 8:  Empty name.
testid = 'Test 8';
[test_dimid, status] = mexnc ( 'def_var', ncid, '', nc_double, 1, xdimid );
if ( status == 0 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid );
	error ( err_msg );
end


% Test 9:  Bogus datatype.
testid = 'Test 9';
fprintf ( 2, 'Bogus character datatype.  Need to rethink this at some point.\n' );
%[test_dimid, status] = mexnc ( 'def_var', ncid, 'xxx', 'bad_data_type', 1, xdimid );
%if ( status == 0 )
%	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid );
%	error ( err_msg );
%end


% Test 10:  Bad number of dimensions.
testid = 'Test 10';
try
	[test_dimid, status] = mexnc ( 'def_var', ncid, 'xxx', nc_double, 5, xdimid );
	error_condition = 1;
end
if error_condition == 1
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid );
	error ( err_msg );
end


% Test 11:  Bogus dimid.
testid = 'Test 11';
[test_dimid, status] = mexnc ( 'def_var', ncid, 'xxx', nc_double, 1, -5 );
if ( status == 0 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid );
	error ( err_msg );
end




% Test 12:  ncid is not numeric
testid = 'Test 12';
try
	[xdvarid, status] = mexnc ( 'def_var', 'ncid', 'x_double12', nc_double, 1, xdimid );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end





% Test 13:  varname is not character
testid = 'Test 13';
try
	[xdvarid, status] = mexnc ( 'def_var', ncid, 25, nc_double, 1, xdimid );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end



% Test 14:  datatype is not character or numeric
testid = 'Test 14';
try
	[xdvarid, status] = mexnc ( 'def_var', ncid, 't14', struct([]), 1, xdimid );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end


% Test 15:  ndims is not numeric
testid = 'Test 15';
try
	[xdvarid, status] = mexnc ( 'def_var', ncid, 't14', nc_double, '1', xdimid );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end


% Test 16:  dimids is not numeric
testid = 'Test 16';
try
	[xdvarid, status] = mexnc ( 'def_var', ncid, 't14', nc_double, 1, 'd');
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end

% Test 17:  try to pass too many dimensions
testid = 'Test 17';
try
	num_dims = 10000;
	[xdvarid, status] = mexnc ( 'def_var', ncid, 't14', nc_double, 10000, xdimid*ones(num_dims,1) );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end




%
% ENDEF
[status] = mexnc ( 'end_def', ncid );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


status = mexnc ( 'close', ncid );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


fprintf ( 1, 'DEF_VAR succeeded.\n' );


return













