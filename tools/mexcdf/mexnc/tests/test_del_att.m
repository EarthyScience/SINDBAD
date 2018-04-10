function test_del_att ( ncfile )
% TEST_DEL_ATT
%
% Test 1:  Delete an attribute.
% Test 2:  Bad ncid.
% Test 3:  Bad varid.
% Test 4:  Empty name.
% Test 5:  Bad name.
% Test 6:  ncid = []
% Test 7:  varid == []
% Test 8:  attname == []
% Test 9:  ncid is wrong datatype
% Test 10:  varid is wrong datatype
% Test 11:  attname is wrong datatype

if nargin == 0
	ncfile = 'foo.nc';
end

error_condition = 0;

[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', 20 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

[varid, status] = mexnc ( 'def_var', ncid, 'x', nc_double, 1, xdimid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

input_data = 3.14159;
status = mexnc ( 'put_att_double', ncid, varid, 'test_double', nc_double, 1, input_data );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


status = mexnc ( 'enddef', ncid  );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


status = mexnc ( 'sync', ncid  );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

status = mexnc ( 'redef', ncid  );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end



%
% Test 1
testid = 'Test 1';
status = mexnc ( 'del_att', ncid, varid, 'test_double' );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

[attnum, status] = mexnc ( 'inq_attid', ncid, varid, 'test_double' );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  attribute was not deleted', mfilename, ncerr );
	error ( err_msg );
end




status = mexnc ( 'put_att_double', ncid, varid, 'to_be_deleted', nc_double, 1, input_data );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end




% Test 2:  Bad ncid.
testid = 'Test 2';
status = mexnc ( 'del_att', -2000, varid, 'to_be_deleted' );
if ( status == 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end







% Test 3:  Bad varid.
testid = 'Test 3';
status = mexnc ( 'del_att', ncid, -2000, 'to_be_deleted' );
if ( status == 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end





% Test 4:  Empty name.
testid = 'Test 4';
try
	status = mexnc ( 'del_att', ncid, varid, '' );
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end





% Test 5:  Bad name.
testid = 'Test 5';
status = mexnc ( 'del_att', ncid, varid, 'I know nothing' );
if ( status == 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end




% Test 6:  ncid == []
testid = 'Test 6';
try
	status = mexnc ( 'del_att', [], varid, 'I know less than nothing' );
	err_msg = sprintf ( '%s:  %s:  succeeded where it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
catch
	;
end






% Test 7:  varid == []
testid = 'Test 7';
try
	status = mexnc ( 'del_att', ncid, [], 'I know less than nothing' );
	err_msg = sprintf ( '%s:  %s:  succeeded where it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
catch
	;
end






% Test 8:  Attribute name == []
testid = 'Test 7';
try
	status = mexnc ( 'del_att', ncid, varid, [] );
	err_msg = sprintf ( '%s:  %s:  succeeded where it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
catch
	;
end



% Test 9:  ncid is wrong datatype
testid = 'Test 9';
try
	status = mexnc ( 'del_att', 'ncid', varid, 'to_be_deleted' );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end


% Test 10:  varid is wrong datatype
testid = 'Test 10';
try
	status = mexnc ( 'del_att', ncid, 'varid', 'to_be_deleted' );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end


% Test 11:  varid is wrong datatype
testid = 'Test 11';
try
	status = mexnc ( 'del_att', ncid, varid, 5 );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end











fprintf ( 1, 'DEL_ATT succeeded.\n' );


status = mexnc ( 'close', ncid );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


return
















