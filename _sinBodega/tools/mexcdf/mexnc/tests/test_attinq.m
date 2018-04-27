function test_attinq ( ncfile )
% TEST_ATTINQ
%
% Test 1:  inquire about double precision attribute of a variable
% Test 2:  try to inquire from a bad ncid
% Test 3:  try to inquire from a bad varid
% Test 4:  try to inquire about non-existant attribute
% Test 5:  try to inquire from empty set ncid
% Test 6:  try to inquire using a bad attribute name


error_condition = 0;

[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status < 0 )
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

[varid, status] = mexnc ( 'def_var', ncid, 'x', nc_double, 1, xdimid );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

%
% Double test
input_data = 3.14159;
status = mexnc ( 'ATTPUT', ncid, varid, 'test_double', nc_double, 1, input_data );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end
[status] = mexnc ( 'enddef', ncid );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end
status = mexnc ( 'sync', ncid );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end



% Test 1:  inquire about double precision attribute of a variable
[datatype, len, status] = mexnc('ATTINQ', ncid, varid, 'test_double');
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end
if ( datatype ~= 6 )
	err_msg = sprintf ( '%s:  returned datatype was not NC_DOUBLE, ATTINQ failed\n', mfilename );
	error ( err_msg );
end
if ( len ~= 1 )
	err_msg = sprintf ( '%s:  returned length was not 1, ATTINQ failed\n', mfilename );
	error ( err_msg );
end


%
% Test 2:  try to inquire from a bad ncid
[datatype, len, status] = mexnc('ATTINQ', -1, varid, 'test_double');
if ( status >= 0 )
	err_msg = sprintf ( '%s:  ATTINQ succeeded on bad ncid\n', mfilename );
	error ( err_msg );
end


%
% Test 3:  try to inquire from a bad varid
[datatype, len, status] = mexnc('ATTINQ', ncid, -5, 'test_double');
if ( status >= 0 )
	err_msg = sprintf ( '%s:  ATTINQ succeeded on bad varid\n', mfilename );
	error ( err_msg );
end



%
% Test 4:  try to inquire from a non existant attribute
[datatype, len, status] = mexnc('ATTINQ', ncid, varid, 'bad');
if ( status >= 0 )
	err_msg = sprintf ( '%s:  ATTINQ succeeded on bad attribute name\n', mfilename );
	error ( err_msg );
end



%
% Test 5:  try to inquire from a non existant attribute
[datatype, len, status] = mexnc('ATTINQ', ncid, varid, 'bad');
if ( status >= 0 )
	err_msg = sprintf ( '%s:  ATTINQ succeeded on bad attribute name\n', mfilename );
	error ( err_msg );
end

%
% Test 6:  try to inquire using a non character attribute name
testid = 'Test 6';
try
	[datatype, len, status] = mexnc('ATTINQ', ncid, varid, int32(5));
	error_condition = 1;
end
if error_condition
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid);
	error ( err_msg );
end



status = mexnc ( 'close', ncid );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

fprintf ( 1, 'ATTINQ succeeded.\n' );


return
















