function test_nc_varsize ( )
% TEST_NC_VARSIZE:
%
% Depends upon nc_add_dimension, nc_addvar
%
% 1st set of tests, routine should fail
% test 1:  no input arguments
% test 2:  1 input
% test 3:  too many inputs
% test 4:  inputs are not all character
% test 5:  not a netcdf file
% test 6:  empty netcdf file
% test 7:  given variable is not present
%
% 2nd set of tests, routine should succeed
% test 8:  given singleton variable is present
% test 9:  given 1D variable is present
% test 10:  given 1D-unlimited-but-empty variable is present
% test 11:  given 2D variable is present

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_varsize.m 3151 2010-06-14 22:55:09Z johnevans007 $
% $LastChangedDate: 2010-06-15 00:55:09 +0200 (ter, 15 Jun 2010) $
% $LastChangedRevision: 3151 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

testroot = fileparts(mfilename('fullpath'));

fprintf('Testing NC_VARSIZE ... ');

v = version('-release');
switch(v)
	case{'14','2006a','2006b'}
	    fprintf('\tSome negative tests filtered out on version %s.\n', v);
    otherwise
		test_nc_varsize_neg;
end


ncfile = fullfile(testroot, 'testdata/full.nc' );
test_singleton (ncfile);
test_1D (ncfile);
test_1D_unlimited_empty (ncfile);
test_2D (ncfile);

fprintf('OK\n');

return










%--------------------------------------------------------------------------
function test_singleton ( ncfile )

varsize = nc_varsize ( ncfile, 's' );
if ( varsize ~= 1 )
	error ( 'varsize was not right.');
end
return









%--------------------------------------------------------------------------
function test_1D ( ncfile )

varsize = nc_varsize ( ncfile, 's' );
if ( varsize ~= 1 )
	error ( 'varsize was not right.');
end
return











%--------------------------------------------------------------------------
function test_1D_unlimited_empty ( ncfile )

varsize = nc_varsize ( ncfile, 't3' );
if getpref('SNCTOOLS','PRESERVE_FVD',false)
    if ( varsize(1) ~= 1 ) && ( varsize(2) ~= 0 )
        error ( '%s:  varsize was not right.\n', mfilename );
    end
else
    if ( varsize(1) ~= 0 ) && ( varsize(2) ~= 1 )
        error ( '%s:  varsize was not right.\n', mfilename );
    end
end
return










%--------------------------------------------------------------------------
function test_2D ( ncfile )


varsize = nc_varsize ( ncfile, 'v' );
if ( varsize(1) ~= 1 ) && ( varsize(2) ~= 1 )
	error ( '%s:  varsize was not right.\n', mfilename );
end
return









