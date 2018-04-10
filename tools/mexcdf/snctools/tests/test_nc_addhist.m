function test_nc_addhist ( ncfile )
% TEST_NC_ADDHIST
%
% Relies upon nc_attget, nc_add_dimension, nc_addvar
% Test 1:  no inputs
% test 2:  too many inputs
% test 3:  first input not a netcdf file
% test 4:  2nd input not character
% test 5:  3rd input not character
% Test 6:  Add history first time to global attributes
% Test 7:  Add history again
% Test 8:  Add history first time to global attributes, nc4
% Test 9:  Add history again, nc4



fprintf('Testing NC_ADDHIST...\n' );

if nargin == 0
	ncfile = 'foo.nc';
end

v = version('-release');
switch(v)
	case{'14','2006a','2006b'}
	    fprintf('\tSome negative tests filtered out on version %s.\n', v);
    otherwise
		test_nc_addhist_neg;
end
run_nc3_tests(ncfile);
run_nc4_tests(ncfile);
fprintf('OK\n');
return


%--------------------------------------------------------------------------
function run_nc3_tests(ncfile)
test_add_global_history ( ncfile );            % #6
test_add_global_history_twice ( ncfile );      % #7

%--------------------------------------------------------------------------
function run_nc4_tests(ncfile)
if ~netcdf4_capable
	fprintf('\tmexnc (netcdf-4) backend testing filtered out on configurations where the library version < 4.\n');
	return
end

test_add_global_history_nc4 ( ncfile );        % #8
test_add_global_history_twice_nc4 ( ncfile );  % #9


return



%--------------------------------------------------------------------------
function test_add_global_history ( ncfile )

create_empty_file ( ncfile, nc_clobber_mode );
histblurb = 'blah';
nc_addhist ( ncfile, histblurb );

hista = nc_attget ( ncfile, nc_global, 'history' );
s = findstr(hista, histblurb );
if isempty(s)
	error('history attribute did not contain first attribution.');
end
return




%--------------------------------------------------------------------------
function test_add_global_history_nc4 ( ncfile )

nc_create_empty(ncfile,nc_netcdf4_classic);
histblurb = 'blah';
nc_addhist ( ncfile, histblurb );

hista = nc_attget ( ncfile, nc_global, 'history' );
s = findstr(hista, histblurb );
if isempty(s)
	error('history attribute did not contain first attribution.');
end

verify_netcdf4(ncfile);
return




%--------------------------------------------------------------------------
function test_add_global_history_twice ( ncfile )

create_empty_file ( ncfile, nc_clobber_mode );
histblurb = 'blah a';
nc_addhist ( ncfile, histblurb );
histblurb2 = 'blah b';
nc_addhist ( ncfile, histblurb2 );
histatt = nc_attget ( ncfile, nc_global, 'history' );
s = findstr(histatt, histblurb2 );
if isempty(s)
	error('history attribute did not contain second attribution');
end
return

%--------------------------------------------------------------------------
function test_add_global_history_twice_nc4 ( ncfile )

nc_create_empty(ncfile,nc_netcdf4_classic);
histblurb = 'blah a';
nc_addhist ( ncfile, histblurb );
histblurb2 = 'blah b';
nc_addhist ( ncfile, histblurb2 );
histatt = nc_attget ( ncfile, nc_global, 'history' );
s = findstr(histatt, histblurb2 );
if isempty(s)
	error('history attribute did not contain second attribution');
end
verify_netcdf4(ncfile);
return
