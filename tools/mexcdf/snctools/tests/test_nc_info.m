function test_nc_info ( )

testroot = fileparts(mfilename('fullpath'));

fprintf('Testing NC_INFO ...\n' );
run_local_nc3_tests(testroot);
run_http_tests;
fprintf('OK\n');
return


%--------------------------------------------------------------------------
function run_http_tests()
if getpref('SNCTOOLS','USE_JAVA',false) ...
        && getpref('SNCTOOLS','TEST_REMOTE',false)
    fprintf ('\trunning http/java tests...\n' );
    test_javaNcid;
else
    fprintf('\tHTTP testing filtered out where USE_JAVA and TEST_REMOTE ');
    fprintf('preferences not both set.\n');
end
return

%--------------------------------------------------------------------------
function run_local_nc3_tests(testroot)
fprintf ('\trunning local netcdf-3 tests...\n' );
test_noInputs;
test_tooManyInputs  (testroot);
test_fileNotNetcdf;
test_emptyNetcdfFile(testroot);
test_dimsButNoVars  (testroot);
test_smorgasborg    (testroot);
return


%--------------------------------------------------------------------------
function test_javaNcid ()
import ucar.nc2.dods.*     
import ucar.nc2.*          

url = 'http://coast-enviro.er.usgs.gov/models/share/balop.nc';
jncid = NetcdfFile.open(url);
nc_info ( jncid );
close(jncid);
return



%--------------------------------------------------------------------------
function test_noInputs( )
try
	nc_info;
catch %#ok<CTCH>
    return
end
error ( 'succeeded when it should have failed.\n'  );





%--------------------------------------------------------------------------
function test_tooManyInputs (testroot)
ncfile = fullfile(testroot, 'testdata/empty.nc');
try
	nc_info ( ncfile, 'blah' );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');





%--------------------------------------------------------------------------
function test_fileNotNetcdf()
ncfile = mfilename;
try
	nc_info ( ncfile );
catch %#ok<CTCH>
    return
end
error ( 'succeeded when it should have failed.' );







%--------------------------------------------------------------------------
function test_emptyNetcdfFile (testroot)

ncfile = fullfile(testroot, 'testdata/empty.nc');

nc = nc_info ( ncfile );
if ~strcmp ( nc.Filename, ncfile )
	error( 'Filename was wrong.');
end
if ( ~isempty ( nc.Dimension ) )
	error( 'Dimension was wrong.');
end
if ( ~isempty ( nc.Dataset ) )
	error( 'Dataset was wrong.');
end
if ( ~isempty ( nc.Attribute ) )
	error('Attribute was wrong.');
end
return









%--------------------------------------------------------------------------
function test_dimsButNoVars (testroot)

ncfile = fullfile(testroot, 'testdata/just_one_dimension.nc');

nc = nc_info ( ncfile );
if ~strcmp ( nc.Filename, ncfile )
	error( 'Filename was wrong.');
end
if ( length ( nc.Dimension ) ~= 1 )
	error( 'Dimension was wrong.');
end
if ( ~isempty ( nc.Dataset ) )
	error( 'Dataset was wrong.');
end
if ( ~isempty ( nc.Attribute ) )
	error( 'Attribute was wrong.');
end
return










%--------------------------------------------------------------------------
function test_smorgasborg (testroot)

ncfile = fullfile(testroot, 'testdata/full.nc');
[p,n,e] = fileparts(ncfile); %#ok<ASGLU>

nc = nc_info ( ncfile );
if ~strcmp ( nc.Filename, ncfile )
	error( 'Filename was wrong.');
end
if ( length ( nc.Dimension ) ~= 5 )
	error( 'Dimension was wrong.');
end
if ( length ( nc.Dataset ) ~= 6 )
	error( 'Dataset was wrong.');
end
if ( length ( nc.Attribute ) ~= 1 )
	error( 'Attribute was wrong.');
end
return






