function test_copy_att ( ncfile1, ncfile2 )
% TEST_COPYATT
%
% Test 1:  copy an attribute.
% Test 2:  try with a bad source ncid
% Test 3:  try with a bad source varid
% Test 4:  try with a bad destination ncid
% Test 5:  try with a bad destination varid
% Test 6:  try with a bad attribute name
% Test 7:  try with non numeric source ncid
% Test 8:  try with non numeric source varid
% Test 9:  try with non numeric target ncid
% Test 10:  try with non numeric target varid


error_condition = 0;

[ncid1, status] = mexnc ( 'create', ncfile1, nc_clobber_mode );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


[xdimid1, status] = mexnc ( 'def_dim', ncid1, 'x', 20 );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

[varid1, status] = mexnc ( 'def_var', ncid1, 'x', nc_double, 1, xdimid1 );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

input_data = [3.14159];
status = mexnc ( 'put_att_double', ncid1, varid1, 'test_double', nc_double, 1, input_data );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end
[status] = mexnc ( 'enddef', ncid1 );

status = mexnc ( 'sync', ncid1 );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end



[ncid2, status] = mexnc ( 'create', ncfile2, nc_clobber_mode );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


[xdimid2, status] = mexnc ( 'def_dim', ncid2, 'x', 20 );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

[varid2, status] = mexnc ( 'def_var', ncid2, 'x', nc_double, 1, xdimid2 );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


% Test 1:  copy an attribute.
testid = 'Test 1';
status = mexnc ( 'copy_att', ncid1, varid1, 'test_double', ncid2, varid2 );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

[status] = mexnc ( 'enddef', ncid2 );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

[return_value, status] = mexnc ( 'get_att_double', ncid2, varid2, 'test_double' );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

if return_value ~= 3.14159
	err_msg = sprintf ( 'COPY_ATT did not seem to work\n', mfilename  );
	error ( err_msg );
end


[status] = mexnc ( 'redef', ncid2 );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

% Test 2:  try with a bad source ncid
testid = 'Test 2';
status = mexnc ( 'copy_att', -2, varid1, 'test_double', ncid2, varid2 );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  %s:  COPY_ATT succeeded when it should have failed.\n', mfilename, testid, ncerr );
	error ( err_msg );
end



% Test 3:  try with a bad source varid
testid = 'Test 3';
status = mexnc ( 'copy_att', ncid1, -2, 'test_double', ncid2, varid2 );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  %s:  COPY_ATT succeeded with a bad varid1 when it should have failed.\n', mfilename, testid, ncerr );
	error ( err_msg );
end



% Test 4:  try with a bad destination ncid
testid = 'Test 4';
status = mexnc ( 'copy_att', ncid1, varid1, 'test_double', -2, varid2 );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  %s:  COPY_ATT succeeded with a bad ncid2 when it should have failed.\n', mfilename, testid, ncerr );
	error ( err_msg );
end



% Test 5:  try with a bad destination varid
testid = 'Test 5';
status = mexnc ( 'copy_att', ncid1, varid1, 'test_double', ncid2, -2 );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  %s:  COPY_ATT succeeded with a bad varid2 when it should have failed.\n', mfilename, testid, ncerr );
	error ( err_msg );
end



% Test 6:  try with a bad attribute name
testid = 'Test 6';
status = mexnc ( 'copy_att', ncid1, varid1, 'i_dont_exist', ncid2, varid2 );
if ( status >= 0 )
	err_msg = sprintf ( '%s:  %s:  COPY_ATT succeeded with a bad attribute name when it should have failed.\n', mfilename, testid, ncerr );
	error ( err_msg );
end




% Test 7:  try with non numeric source ncid
testid = 'Test 7';
try
	status = mexnc ( 'copy_att', 'ncid1', varid1, 'test_double', ncid2, varid2 );
	error_condition = 1;
end
if error_condition
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed.\n', mfilename, testid );
	error ( err_msg );
end



% Test 8:  try with non numeric source varid
testid = 'Test 8';
try
	status = mexnc ( 'copy_att', ncid1, 'varid1', 'test_double', ncid2, varid2 );
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed.\n', mfilename, testid );
	error ( err_msg );
end



% Test 9:  try with non numeric target ncid
testid = 'Test 9';
try
	status = mexnc ( 'copy_att', ncid1, varid1, 'test_double', 'ncid2', varid2 );
	error_condition = 1;
end
if error_condition
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed.\n', mfilename, testid );
	error ( err_msg );
end



% Test 10:  try with non numeric target varid
testid = 'Test 10';
try
	status = mexnc ( 'copy_att', ncid1, varid1, 'test_double', ncid2, 'varid2' );
	error_condition = 1;
end
if error_condition
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed.\n', mfilename, testid );
	error ( err_msg );
end





fprintf ( 1, 'COPY_ATT succeeded.\n' );

status = mexnc ( 'close', ncid1 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

status = mexnc ( 'close', ncid2 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


return

















