function test_nc_addhist_neg()
% negative testing for benefit of 2007a and higher.

ncfile = 'foo.nc';

test_no_inputs;                                % #1
test_too_many_inputs ( ncfile );               % #2
test_not_netcdf_file ( ncfile );               % #3
test_2nd_input_not_char ( ncfile );            % #4
test_3rd_input_not_char ( ncfile );            % #5

return


%--------------------------------------------------------------------------
function test_no_inputs (  )
try
	nc_addhist;
catch %#ok<CTCH>
	return
end
error('succeeded when it should have failed.' );



%--------------------------------------------------------------------------
function test_too_many_inputs ( ncfile )
try
	nc_addhist ( ncfile, 'x', 'blurb', 'blurb' );
catch %#ok<CTCH>
	return
end
error('succeeded when it should have failed.');






%--------------------------------------------------------------------------
function test_not_netcdf_file ( ncfile )

create_empty_file ( ncfile, nc_clobber_mode );
try
	nc_addhist ( 'asdfjsadjfsadlkjfsa;ljf;l', 'test' );
catch %#ok<CTCH>
	return
end
error ('succeeded when it should have failed.');





%--------------------------------------------------------------------------
function test_2nd_input_not_char ( ncfile )

create_empty_file ( ncfile, nc_clobber_mode );
try
	nc_addhist ( ncfile, 5 );
catch %#ok<CTCH>
	return
end
error ('succeeded when it should have failed.');




%--------------------------------------------------------------------------
function test_3rd_input_not_char ( ncfile )

create_empty_file ( ncfile, nc_clobber_mode );
nc_add_dimension ( ncfile, 't', 0 );
clear varstruct;
varstruct.Name = 'T';
nc_addvar ( ncfile, varstruct );
try
	nc_addhist ( ncfile, 'T', 5 );
catch %#ok<CTCH>
	return
end
error ('succeeded when it should have failed.');




