function test_nc_addrecs_neg()
% Negative testing for NC_ADDRECS.  Makes use of try/catch, so 2006b and earlier can't do this.

ncfile = 'foo.nc';
create_ncfile ( ncfile )
		
% negative tests
test_no_inputs;
test_only_one_input ( ncfile );
test_2nd_input_not_structure ( ncfile );
test_2nd_input_is_empty_structure ( ncfile );
test_2nd_input_has_bad_fieldnames ( ncfile );
test_one_field_not_unlimited ( ncfile );
test_no_unlimited_dimension ( ncfile );

return




%--------------------------------------------------------------------------
function create_ncfile ( ncfile )

if snctools_use_tmw
    ncid = netcdf.create(ncfile, nc_clobber_mode );
    %
    % Create a fixed dimension.  
    len_x = 4;
    netcdf.defDim(ncid, 'x', len_x );

    len_t = 0;
    netcdf.defDim(ncid, 'time', len_t );

    netcdf.close(ncid);
else
    %
    % ok, first create this baby.
    [ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
    if ( status ~= 0 )
        error ( mexnc ( 'strerror', status ) );
    end
    
    
    %
    % Create a fixed dimension.  
    len_x = 4;
    [xdimid, status] = mexnc ( 'def_dim', ncid, 'x', len_x ); %#ok<ASGLU>
    if ( status ~= 0 )
        error( mexnc ( 'strerror', status ) );
    end
    
    
    len_t = 0;
    [ydimid, status] = mexnc ( 'def_dim', ncid, 'time', len_t ); %#ok<ASGLU>
    if ( status ~= 0 )
        error( mexnc ( 'strerror', status ) );
    end
    
    
    status = mexnc ( 'close', ncid );
    if ( status ~= 0 )
        error ( 'CLOSE failed' );
    end
end


%
% Add a variable along the time dimension
varstruct.Name = 'test_var';
varstruct.Nctype = 'float';
varstruct.Dimension = { 'time' };
varstruct.Attribute(1).Name = 'long_name';
varstruct.Attribute(1).Value = 'This is a test';
varstruct.Attribute(2).Name = 'short_val';
varstruct.Attribute(2).Value = int16(5);

nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 'test_var2';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'time' };

nc_addvar ( ncfile, varstruct );



clear varstruct;
varstruct.Name = 'test_var3';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };

nc_addvar ( ncfile, varstruct );

return





function test_no_inputs (  )

% Try no inputs
try
    nc_addrecs;
catch %#ok<CTCH>
    return
end
error ( 'succeeded on no inputs, should have failed' );








function test_only_one_input ( ncfile )
%
% Try one input, should fail
try
    nc_addrecs ( ncfile );
catch %#ok<CTCH>
    return
end
error ( 'nc_addrecs succeeded on one input, should have failed');









function test_2nd_input_not_structure ( ncfile )


% Try with 2nd input that isn't a structure.
try
    nc_addrecs ( ncfile, [] );
catch %#ok<CTCH>
    return
end
error ( 'nc_addrecs succeeded on one input, should have failed');












function test_2nd_input_is_empty_structure ( ncfile )

%
% Try with 2nd input that is an empty structure.
try
    nc_addrecs ( ncfile, struct([]) );
catch %#ok<CTCH>
    return
end
error ( 'nc_addrecs succeeded on empty structure, should have failed');










function test_2nd_input_has_bad_fieldnames ( ncfile )

%
% Try a structure with bad names
input_data.a = [3 4];
input_data.b = [5 6];
try
    nc_addrecs ( ncfile, input_data );
catch %#ok<CTCH>
    return
end
error ( 'nc_addrecs succeeded on a structure with bad names, should have failed');




function test_one_field_not_unlimited ( ncfile )

% Try writing to a fixed size variable

input_buffer.test_var = single([3 4 5]');
input_buffer.test_var2 = [3 4 5]';
input_buffer.test_var3 = [3 4 5]';

try
    nc_addrecs ( ncfile, input_buffer );
catch %#ok<CTCH>
    return
end
error ( 'nc_addrecs succeeded on writing to a fixed size variable, should have failed.');






function test_no_unlimited_dimension ( ncfile )


if snctools_use_tmw
    ncid = netcdf.create(ncfile, nc_clobber_mode );
    %
    % Create a fixed dimension.  
    len_x = 4;
    netcdf.defDim(ncid, 'x', len_x );

    netcdf.close(ncid);
else
    %
    % ok, first create this baby.
    [ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        error(ncerr_msg);
    end
    
    
    %
    % Create a fixed dimension.  
    len_x = 4;
    [xdimid, status] = mexnc ( 'def_dim', ncid, 'x', len_x ); %#ok<ASGLU>
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        error( ncerr_msg );
    end
    
    
    
    %
    % CLOSE
    status = mexnc ( 'close', ncid );
    if ( status ~= 0 )
        error ( 'CLOSE failed' );
    end
end


clear varstruct;
varstruct.Name = 'test_var3';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };

nc_addvar ( ncfile, varstruct );


input_buffer.time = [1 2 3]';
try
    nc_addrecs ( ncfile, input_buffer );
catch %#ok<CTCH>
    return
end
error ( 'nc_addrecs passed when writing to a file with no unlimited dimension');




