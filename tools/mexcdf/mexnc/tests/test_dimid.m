function test_dimid ( ncfile )
% TEST_DIMID
%
% Test 1:  Retrieve a dimid.
% Test 2:  Bad ncid.
% Test 3:  Empty set ncid.
% Test 4:  Empty string dim name.
% Test 5:  Empty set dim name.
% Test 6:  Bad dim name.



[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


%
% DIMDEF
[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', 20 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

[status] = mexnc ( 'enddef', ncid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

% Test 1:  Retrieve a dimid.
testid = 'Test 1';
[dimid, status] = mexnc('DIMID', ncid, 'x');
if ( dimid ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end
if ( status ~= 0 )
	error ( 'DIMID return status failed on bogus test' );
end

if dimid ~= xdimid
	err_msg = sprintf ( '%s:  DIMID did not return the expected value.\n', mfilename, ncerr );
	error ( err_msg );
end

% Test 2:  Bad ncid.
testid = 'Test 2';
[test_dimid, status] = mexnc ( 'dimid', -2, 'x' );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  %s:  Succeeded when it should have failed\n', mfilename, testid );
	error ( err_msg );
end




% Test 3:  Empty set ncid.
testid = 'Test 3';
try
	[test_dimid, status] = mexnc ( 'dimid', [], 'x' );
	err_msg = sprintf ( '%s:  %s:  Succeeded when it should have failed\n', mfilename, testid );
	error ( err_msg );
end




% Test 4:  Empty string dim name.
testid = 'Test 4';
try
	[test_dimid, status] = mexnc ( 'dimid', ncid, '' );
	err_msg = sprintf ( '%s:  %s:  Succeeded when it should have failed\n', mfilename, testid );
	error ( err_msg );
end




% Test 5:  Empty set dim name.
testid = 'Test 5';
try
	[test_dimid, status] = mexnc ( 'dimid', ncid, [] );
	err_msg = sprintf ( '%s:  %s:  Succeeded when it should have failed\n', mfilename, testid );
	error ( err_msg );
end






% Test 6:  Bad dim  name
testid = 'Test 6';
[test_dimid, status] = mexnc ( 'dimid', ncid, 'y' );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  DIMID succeeded on a bad name\n', mfilename );
	error ( err_msg );
end




status = mexnc ( 'close', ncid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


fprintf ( 1, 'DIMID succeeded.\n' );


return















