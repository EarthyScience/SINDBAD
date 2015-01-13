function test_nc_isatt ( )

global ignore_eids;
ignore_eids = getpref('SNCTOOLS','IGNOREEIDS',true);

fprintf ('Testing NC_ISATT...\n' );

testroot = fileparts(mfilename('fullpath'));

run_nc3_tests     (testroot);
run_hdf4_tests    (testroot);
run_nc4_tests     (testroot);
run_nc4_java_tests(testroot);
run_java_tests    (testroot);



%--------------------------------------------------------------------------
function run_java_tests(testroot)
if ~getpref('SNCTOOLS','USE_JAVA',false)
    fprintf('\tjava backend testing filtered out on ');
    fprintf('configurations where SNCTOOLS ''USE_JAVA'' ');
    fprintf('prefererence is false.\n');
    return
end
run_http_tests;
run_grib2_tests(testroot);
return


%--------------------------------------------------------------------------
function run_grib2_tests(testroot)
fprintf('\tRunning grib2 tests...\n');
gribfile = fullfile(testroot,'testdata',...
    'ecmf_20070122_pf_regular_ll_pt_320_pv_grid_simple.grib2');
test_grib2_char(gribfile);
return

%--------------------------------------------------------------------------
function test_grib2_char(gribfile)
if ~getpref('SNCTOOLS','TEST_GRIB2',false)
    fprintf('GRIB2 testing filtered out where SNCTOOLS preference ');
    fprintf('TEST_GRIB2 is set to false.\n');
    return
end
act_data = nc_isatt(gribfile,-1,'creator_name');
if ~act_data
    error('failed'); 
end
return

%--------------------------------------------------------------------------
function run_nc3_tests(testroot)
	fprintf('\tRunning local netcdf-3 tests.\n');
	ncfile = fullfile(testroot,'testdata/attget.nc');
	run_local_tests(ncfile);
return

%--------------------------------------------------------------------------
function run_hdf4_tests(testroot)
	fprintf('\tRunning local HDF4 tests.\n');
	hfile = fullfile(testroot,'testdata/attget.hdf');
	run_local_tests(hfile);    
return
%--------------------------------------------------------------------------
function run_nc4_tests(testroot)
	if getpref('SNCTOOLS','USE_JAVA',false)
		fprintf('\tmexnc (netcdf-4) backend testing filtered out on ');
        fprintf('configurations where SNCTOOLS ''USE_JAVA'' ');
        fprintf('prefererence is true.\n');
		return
	end
	if ~netcdf4_capable
		fprintf('\tmexnc (netcdf-4) backend testing filtered out on ');
        fprintf('configurations where the library version < 4.\n');
		return
	end
	fprintf('\tRunning local netcdf-4 tests.\n');
	ncfile = fullfile(testroot,'testdata/attget-4.nc');
	run_local_tests(ncfile);
return

%--------------------------------------------------------------------------
function run_nc4_java_tests(testroot)
	if ~getpref('SNCTOOLS','USE_JAVA',false)
		fprintf('\tjava nc4 backend testing filtered out on ');
        fprintf('configurations where SNCTOOLS ''USE_JAVA'' ');
        fprintf('prefererence is false.\n');
		return
	end
	fprintf('\tRunning local netcdf4/java tests.\n');
	ncfile = fullfile(testroot,'testdata/attget-4.nc');
	run_local_tests(ncfile);
return








%--------------------------------------------------------------------------
function run_local_tests(ncfile)

test_present ( ncfile );
test_not_present ( ncfile );
test_global_att(ncfile);
return;


%--------------------------------------------------------------------------
function test_global_att(ncfile)
% Check for existence of a global attribute.

if ~nc_isatt(ncfile,nc_global,'test_double_att')
    error('failed');
end

%--------------------------------------------------------------------------
function run_http_tests()
	% These tests are regular URLs, not OPeNDAP URLs.
	if ~ ( getpref ( 'SNCTOOLS', 'USE_JAVA', false ) )
		fprintf('\tjava http backend testing filtered out when SNCTOOLS ');
        fprintf('''USE_JAVA'' preference is false.\n');
		return
	end
	if ~ ( getpref ( 'SNCTOOLS', 'TEST_REMOTE', false ) )
		fprintf('\tjava http backend testing filtered out when SNCTOOLS ');
        fprintf('''TEST_REMOTE'' preference is false.\n');
		return
	end
	fprintf('\tRunning http/java tests.\n');
	test_present_attr_HTTP;
	test_not_present_attr_HTTP;
return







%--------------------------------------------------------------------------
function test_present_attr_HTTP ()

url = 'http://rocky.umeoce.maine.edu/GoMPOM/cdfs/gomoos.20070723.cdf';

bool = nc_isatt ( url, 'w', 'valid_range' );
if ~bool
	error ( 'failed' );
end
return


%--------------------------------------------------------------------------
function test_not_present_attr_HTTP ()

url = 'http://rocky.umeoce.maine.edu/GoMPOM/cdfs/gomoos.20070723.cdf';

bool = nc_isatt ( url, 'w', 'valid_range_49' );
if bool
	error ( 'failed' );
end
return


%--------------------------------------------------------------------------
function test_present ( ncfile )

bool = nc_isatt ( ncfile, 'x_db', 'test_double_att' );
if ~bool
	error('failed');
end

return


%--------------------------------------------------------------------------
function test_not_present ( ncfile )

bool = nc_isatt ( ncfile, 'x_db', 'test_double_att_49' );
if bool
	error('failed');
end

return

