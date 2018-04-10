function test_nc_varrename ( ncfile )
% TEST_NC_ISVAR:
%
% Depends upon nc_add_dimension, nc_addvar
%
% 1st set of tests, routine should fail
% test no input arguments
% test only 1 input
% test only 2 inputs
% test too many inputs
% test inputs are not all character
% test empty netcdf file
% test given variable is not present
%
% 2nd set of tests, routine should succeed
% test given variable is present

%
% 3rd set should fail
% test given variable is present, but another exists with the same name

global ignore_eids;
ignore_eids = getpref('SNCTOOLS','IGNOREEIDS',true);

fprintf ( 1, 'Testing NC_VARRENAME... \n' );
if nargin == 0
	ncfile = 'foo.nc';
end

v = version('-release');
switch(v)
	case{'14','2006a','2006b'}
	    fprintf('\tSome negative tests filtered out on version %s.\n', v);
    otherwise
		test_nc_varrename_neg;
end

run_nc3_tests(ncfile);
run_nc4_tests(ncfile);
fprintf('OK\n');
return


%--------------------------------------------------------------------------
function run_nc3_tests(ncfile)

mode = nc_clobber_mode;
test_variable_is_present ( ncfile,mode );
return


%--------------------------------------------------------------------------
function run_nc4_tests(ncfile)

if ~netcdf4_capable
	fprintf('\tmexnc (netcdf-4) backend testing filtered out on configurations where the library version < 4.\n');
	return
end

mode = bitor(nc_clobber_mode,nc_netcdf4_classic);
test_variable_is_present ( ncfile,mode );

return




















%--------------------------------------------------------------------------
function test_variable_is_present ( ncfile,mode )


create_empty_file ( ncfile,mode );
nc_add_dimension ( ncfile, 's', 5 );
nc_add_dimension ( ncfile, 't', 0 );
clear varstruct;
varstruct.Name = 't';
varstruct.Nctype = 'double';
varstruct.Dimension = { 't' };
nc_addvar ( ncfile, varstruct );

nc_varrename ( ncfile, 't', 't2' );



v = nc_getvarinfo ( ncfile, 't2' );
if ~strcmp ( v.Name, 't2' )
	error('rename did not seem to work.');
end

return










