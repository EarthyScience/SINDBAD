function test__enddef ( ncfile, ncfile2 )
% TEST__ENDDEF:
%
% 


error_condition = 0;

[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


%
% Define a dimension and a variable.
[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', 20 );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

[xdvarid, status] = mexnc ( 'def_var', ncid, 'x_double', nc_double, 1, xdimid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


%
% End the definitions, but leave space in the header.
% Usually, nc_enddef(ncid) is equivalent to nc__enddef ( ncid, 0, 4, 0, 4 );
[status] = mexnc ( '_enddef', ncid, 20000, 4, 0, 4 );
%[status] = mexnc ( 'enddef', ncid );
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



d = dir ( ncfile );
if d.bytes < 20000
	msg = sprintf ( '%s:  %s:  __enddef didn''t work.\n', mfilename, testid );
	error ( msg );
end





fprintf ( 1, '__ENDDEF succeeded.\n' );


return













