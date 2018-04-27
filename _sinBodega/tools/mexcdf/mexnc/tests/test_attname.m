function test_attname ( ncfile )
% TEST_ATTNAME
%
% Test 1:  Write an attribute then test for existance.
% Test 2:  Inquire from a bad source ncid.  Should fail.
% Test 3:  Inquire from a bad source varid.  Should fail.
% Test 4:  Inquire from a bad attnum.  Should fail.



[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


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

input_data = [3.14159];
status = mexnc ( 'put_att_double', ncid, varid, 'test_double', nc_double, 1, input_data );
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


[attnum, status] = mexnc ( 'inq_attid', ncid, varid, 'test_double' );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end




% Test 1:  Write an attribute then test for existance.
[attname, status] = mexnc ( 'attname', ncid, varid, attnum );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

if ( ~strcmp ( attname, 'test_double' ) )
	err_msg = sprintf ( '%s:  attribute name retrieved by ATTNAME did not match what we put in there\n', mfilename );
	error ( err_msg );
end




% Test 2:  Inquire from a bad source ncid.  Should fail.
[attname, status] = mexnc ( 'attname', -5, varid, attnum );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  ATTNAME succeeded with a bad ncid\n', mfilename);
	error ( err_msg );
end




% Test 3:  Inquire from a bad source varid.  Should fail.
[attname, status] = mexnc ( 'attname', ncid, -5, attnum );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  ATTNAME succeeded with a bad varid\n', mfilename);
	error ( err_msg );
end



% Test 4:  Inquire from a bad attnum.  Should fail.
[attname, status] = mexnc ( 'attname', ncid, varid, -89877 );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  ATTNAME succeeded with a bad attnum\n', mfilename);
	error ( err_msg );
end




status = mexnc ( 'close', ncid );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

fprintf ( 1, 'ATTNAME succeeded.\n' );

return
















