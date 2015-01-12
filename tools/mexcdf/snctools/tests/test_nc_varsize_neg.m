function test_nc_varsize_neg()
% negative testing for nc_varsize

testroot = fileparts(mfilename('fullpath'));

ncfile = fullfile(testroot, 'testdata/empty.nc' );

test_no_inputs;
test_only_one_input (ncfile);
test_too_many_inputs (ncfile);
test_varname_not_char (ncfile);
test_not_netcdf;
test_empty (ncfile);

ncfile = fullfile(testroot, 'testdata/full.nc' );
test_var_not_present (ncfile);
return



%--------------------------------------------------------------------------
function test_no_inputs ()

try
	nc_varsize;
catch %#ok<CTCH>
    return
end
error('failed');













%--------------------------------------------------------------------------
function test_only_one_input( ncfile )

try
	nc_varsize ( ncfile );
catch %#ok<CTCH>
    return
end
error('failed');











%--------------------------------------------------------------------------
function test_too_many_inputs( ncfile )

try
	nc_varsize ( ncfile, 'x', 'y' );
catch %#ok<CTCH>
    return
end
error('failed');











%--------------------------------------------------------------------------
function test_varname_not_char ( ncfile )

try
	nc_varsize ( ncfile, 1 );
catch %#ok<CTCH>
    return
end
error('failed');












%--------------------------------------------------------------------------
function test_not_netcdf ( )

% test 5:  not a netcdf file
try
	nc_varsize ( mfilename, 't' );
catch %#ok<CTCH>
    return
end
error('failed');















%--------------------------------------------------------------------------
function test_empty ( ncfile )

% no such variable
try
	nc_varsize ( ncfile, 't' );
catch %#ok<CTCH>
    return
end
error('failed');












%--------------------------------------------------------------------------
function test_var_not_present ( ncfile )

try
	nc_varsize ( ncfile, 'xyz' );
catch %#ok<CTCH>
    return
end
error('failed');






