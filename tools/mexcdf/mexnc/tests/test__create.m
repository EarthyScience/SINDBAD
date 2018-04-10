function test__create ( ncfile )
% TEST__CREATE:
%
% Tests run are open with
% Test 1:   nc_clobber_mode.  Check the initial file size.
% Test 2:   nc_noclobber_mode
% Test 3:   clobber and share and 64 bit offset
% Test 4:  share mode.  Should also clobber it.
% Test 5:  share | 64bit_offset
% Test 6:  64 bit offset.  Should also clobber it.
% Test 7:  noclobber mode.  Should not succeed.
% Test 8:  only one input, should not succeed
% Test 9:  Filename is empty
% Test 10:  mode argument not supplied
%
% Basically the tests are the same as those for CREATE except we are
% using _CREATE instead.
%
% The _CREATE routine really isn't necesary anymore in NetCDF-4.  This
% is for backwards compatibility only.

if nargin == 0
	ncfile = 'foo.nc';
end

error_condition = 0;

%
% Test 1:   nc_clobber_mode
testid = 'Test 1';
[chunksize,ncid, status] = mexnc ( '_create', ncfile, nc_clobber_mode, 5000 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

d = dir ( ncfile );
if d.bytes ~= 5000
	msg = sprintf ( '%s:  %s:  initialsize not honored.\n', mfilename, testid );
	error ( msg );
end
status = mexnc ( 'close', ncid );
if ( status ~= 0 )
	error ( 'CLOSE failed with nc_clobber_mode' );
end





%
% Test 2:   nc_noclobber_mode | nc_share_mode
testid = 'Test 2';
mode = bitor ( nc_clobber_mode, nc_share_mode );
[chunksize, ncid, status] = mexnc ( '_create', ncfile, mode, 5000 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end
status = mexnc ( 'close', ncid );
if ( status < 0 )
	error ( 'CLOSE failed with nc_clobber_mode | nc_share_mode' );
end




%
% Test 3:   clobber and share and 64 bit offset
testid = 'Test 3';
mode = bitor ( nc_clobber_mode, nc_share_mode );
mode = bitor ( mode, nc_64bit_offset_mode );
[chunksize, ncid, status] = mexnc ( '_create', ncfile, mode, 5000 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end
status = mexnc ( 'close', ncid );
if ( status < 0 )
	error ( 'CLOSE failed with nc_clobber_mode | nc_share_mode | nc_64bit_offset_mode' );
end


%
% Test 4:  share mode.  Should also clobber it.
testid = 'Test 4';
[chunksize, ncid, status] = mexnc ( '_create', ncfile, nc_share_mode, 5000 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end
status = mexnc ( 'close', ncid );
if ( status < 0 )
	error ( 'CLOSE failed with nc_share_mode' );
end


%
% Test 5:  share | 64bit_offset
testid = 'Test 5';
mode = bitor ( nc_share_mode, nc_64bit_offset_mode );
[chunksize, ncid, status] = mexnc ( '_create', ncfile, mode, 5000 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end
status = mexnc ( 'close', ncid );
if ( status < 0 )
	error ( 'CLOSE failed with nc_share_mode | nc_64bit_offset_mode' );
end



%
% Test 6:  64 bit offset.  Should also clobber it.
testid = 'Test 6';
[chunksize, ncid, status] = mexnc ( '_create', ncfile, nc_64bit_offset_mode, 5000 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end
status = mexnc ( 'close', ncid );
if ( status < 0 )
	error ( 'CLOSE failed with nc_64bit_offset_mode' );
end


%
% Test 7:  noclobber mode.  Should not succeed.
testid = 'Test 7';
[chunksize, ncid, status] = mexnc ( '_create', ncfile, nc_noclobber_mode, 5000 );
if ( status == 0 )
	msg = sprintf ( '%s:  ''_create'' succeeded on nc_noclobber_mode, should have failed\n', mfilename );
	error ( msg );
end


%
% Test 8:  only one input, should not succeed.  Throws an exception, 
%          because there are way too few arguments.
testid = 'Test 8';
try
	[chunksize, ncid, status] = mexnc ( '_create' );
	msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid );
	error ( msg );
catch	
	;
end





%
% Test 9:  Filename is empty
testid = 'Test 9';
try
	[chunksize, ncid, status] = mexnc ( '_create', '', nc_clobber_mode, 5000 );
	msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid );
	error ( msg );
end





fprintf ( '_CREATE succeeded.\n' );

return






%
% Test 11:  3rd argument is not a valid mode
testid = 'Test 11';
[ncid, status] = mexnc ( '_create', ncfile, -5 );
if ( status == 0 )
	msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid );
	error ( msg );
end




return
