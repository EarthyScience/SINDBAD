function test_vardef ( ncfile )
% TEST_VARDEF
%

%
% Test 2:  Create a singleton dimension using [] as the list of dimids.
% Test 3:  Create a singleton dimension using 0 as the number of dimids


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

[xdvarid, status] = mexnc ( 'vardef', ncid, 'x_double', 'double', 1, xdimid );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

%
% Try a bad ncid.
[test_dimid, status] = mexnc ( 'vardef', -2, 'x_double', 'double', 1, xdimid );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  DEF_VAR succeeded on a bad ncid\n', mfilename );
	error ( err_msg );
end


%
% Try a bad dimid.
[test_dimid, status] = mexnc ( 'vardef', ncid, 'x_double', 'double', 1, -3 );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  DEF_VAR succeeded on a bad ncid\n', mfilename );
	error ( err_msg );
end

% 
% Test 2
testid = 'Test 2';
[singleton, status] = mexnc ( 'vardef', ncid, 'x_empty', 'double', 0, [] );
if status
	err_msg = sprintf ( '%s:  %s:  VARDEF failed\n', mfilename, testid );
	error ( err_msg );
end



%
% ENDEF
[status] = mexnc ( 'enddef', ncid );
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


fprintf ( 1, 'VARDEF succeeded.\n' );


return














