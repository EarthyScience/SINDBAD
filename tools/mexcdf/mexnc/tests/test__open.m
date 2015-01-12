function test__open ( ncfile )
% Tests run are
%
% Test 1:  test write mode
% Test 2:  test share mode
% Test 3:  bitwise or of write mode and share mode
% Test 4:  only two input arguments given
% Test 5:  filename argument is bad
% Test 6:  filename argument is non character
% Test 7:  mode argument is non character and non double
% Test 8:  mode argument is character, but unknown

error_condition = 0;

%
% ok, first create this baby.
[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status ~= 0 )
    error ( mexnc('strerror',status) );
end
status = mexnc ( 'close', ncid );
if ( status ~= 0 )
    error ( mexnc('strerror',status) );
end


%
% Test 1:   write mode
[chunksizehint, ncid, status] = mexnc ( '_open', ncfile, nc_write_mode, 1024 );
if ( status ~= 0 )
    error ( mexnc('strerror',status) );
end
status = mexnc ( 'close', ncid );
if ( status ~= 0 )
    error ( mexnc('strerror',status) );
end

%
% Test 2:  share mode
[chunksizehint, ncid, status] = mexnc ( '_open', ncfile, nc_share_mode, 1024 );
if ( status ~= 0 )
    error ( mexnc('strerror',status) );
end
status = mexnc ( 'close', ncid );
if ( status ~= 0 )
    error ( mexnc('strerror',status) );
end



%
% Test 3:  bitwise or of write mode and share mode
[chunksizehint, ncid, status] = mexnc ( '_open', ncfile, bitor ( nc_write_mode, nc_share_mode ) , 1024);
if ( status ~= 0 )
    error ( mexnc('strerror',status) );
end
status = mexnc ( 'close', ncid );
if ( status ~= 0 )
    error ( mexnc('strerror',status) );
end


%
% Test 4:  only two input arguments given
testid = 'Test 5';
try
	[csh, ncid, status] = mexnc ( '_open', ncfile, 1024 );
	mexnc ( 'close', ncid );
	msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, mexnc ( 'strerror', status ) );
	error ( msg );
end



% Test 5:  filename argument is bad
testid = 'Test 5';
[csh, ncid, status] = mexnc ( '_open', 'i_do_not_exists', nc_noclobber_mode, 1024 );
if ( status == 0 )
	msg = sprintf ( '%s:  %s:  succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end


% Test 6:  filename argument is non character
testid = 'Test 6';
try
	[csh, ncid, status] = mexnc ( '_open', 20000, nc_noclobber_mode, 1024 );
	error_condition = 1;
end
if error_condition == 1
	err_msg = sprintf ( '%s:  %s:  Succeeded when it should have failed\n', mfilename, testid );
	error ( err_msg );
end



% Test 7:  mode argument is non character and non double
testid = 'Test 7';
try
	[csh, ncid, status] = mexnc ( '_open', ncfile, single(5), 1024 );
	error_condition = 1;
end
if error_condition == 1
	err_msg = sprintf ( '%s:  %s:  Succeeded when it should have failed\n', mfilename, testid );
	error ( err_msg );
end



fprintf ( 1, '_OPEN succeeded.\n' );




return
