function test_attdel ( ncfile )
% TEST_ATTDEL
%
% Test 1:  delete a double precision attribute of a variable
% Test 2:  try to delete from a bad ncid
% Test 3:  try to delete from a bad varid
% Test 4:  try to delete a non-existant attribute
% Test 5:  try to use a non numeric attid or non char attribute name


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

input_data = 3.14159;
status = mexnc ( 'put_att_double', ncid, varid, 'test_double', nc_double, 1, input_data );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end



% Test 1:  delete a double precision attribute of a variable
status = mexnc ( 'ATTDEL', ncid, varid, 'test_double' );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

[attnum, status] = mexnc ( 'inq_attid', ncid, varid, 'test_double' );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  attribute was not deleted', mfilename, ncerr );
	error ( err_msg );
end


%
% Test 2:  try to delete from a bad ncid
status = mexnc ( 'ATTDEL', -5, varid, 'test_double' );
if ( status ~= -1 )
	err_msg = sprintf ( '%s:  ATTDEL succeeded on a bad ncid.\n', mfilename );
	error ( err_msg );
end


%
% Test 3:  try to delete from a bad varid
status = mexnc ( 'ATTDEL', ncid, -5, 'test_double' );
if ( status ~= -1 )
	err_msg = sprintf ( '%s:  ATTDEL succeeded on a bad varid.\n', mfilename );
	error ( err_msg );
end


%
% Test 4:  try to delete a non-existant attribute
status = mexnc ( 'ATTDEL', ncid, varid, 'blah' );
if ( status ~= -1 )
	err_msg = sprintf ( '%s:  ATTDEL succeeded on a bad attribute name.\n', mfilename );
	error ( err_msg );
end


fprintf ( 1, 'ATTDEL succeeded.\n' );


status = mexnc ( 'close', ncid );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


return


















