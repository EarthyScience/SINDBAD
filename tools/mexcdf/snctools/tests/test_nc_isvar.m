function test_nc_isvar ( )

testroot = fileparts(mfilename('fullpath'));

fprintf('Testing NC_ISVAR ...\n' );
run_nc3_tests(testroot);
run_nc4_tests(testroot);
run_java_tests(testroot);
fprintf('OK\n');

return


%--------------------------------------------------------------------------
function run_nc3_tests(testroot)
	fprintf('\tRunning nc3 tests...\n' );
	ncfile = fullfile(testroot,'testdata/empty.nc');
	test_noArgs;
	test_oneArg             ( ncfile );
	test_tooManyArgs        ( ncfile );
	test_varnameNotChar ;
	test_notNetcdfFile;
	test_emptyFile          ( ncfile );
	test_dimsButNoVars      ( ncfile );

	ncfile = fullfile(testroot,'testdata/full.nc');
	test_variableNotPresent ( ncfile );
	test_variablePresent    ( ncfile );
return


%--------------------------------------------------------------------------
function run_nc4_tests(testroot)
	if ~netcdf4_capable
		fprintf('\tmexnc (netcdf-4) backend testing filtered out on ');
        fprintf('configurations where the library version < 4.\n');
		return
	end
	fprintf('\tRunning nc4 tests...\n' );
	ncfile = fullfile(testroot,'testdata/empty-4.nc');
	test_noArgs;
	test_oneArg             ( ncfile );
	test_tooManyArgs        ( ncfile );
	test_varnameNotChar ;
	test_notNetcdfFile;
	test_emptyFile          ( ncfile );
	test_dimsButNoVars      ( ncfile );

	ncfile = fullfile(testroot,'testdata/full-4.nc');
	test_variableNotPresent ( ncfile );
	test_variablePresent    ( ncfile );
return


%--------------------------------------------------------------------------
function run_java_tests(testroot) %#ok<INUSD>
    if ~getpref('SNCTOOLS','USE_JAVA',false)
        fprintf ( '\tjava backend testing filtered out on ');
        fprintf ( 'configurations where SNCTOOLS ''USE_JAVA'' ');
        fprintf ( 'prefererence is false.\n' );
        return;
    end
	if ~getpref('SNCTOOLS','TEST_REMOTE',false)
		fprintf ( '\tjava remote testing filtered out on ');
        fprintf ('configurations where SNCTOOLS ''TEST_REMOTE'' ');
        fprintf ('prefererence is false.\n' );
		return
	end    
	fprintf('\tRunning java http tests...\n' );
	test_javaNcidHttp ;
return



%--------------------------------------------------------------------------
function test_noArgs()

try
	nc = nc_isvar; %#ok<NASGU>
	error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end










%--------------------------------------------------------------------------
function test_oneArg ( ncfile )

try
	nc = nc_isvar ( ncfile ); %#ok<NASGU>
	error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end










%--------------------------------------------------------------------------
function test_tooManyArgs ( ncfile )

try
	nc = nc_isvar ( ncfile, 'blah', 'blah2' ); %#ok<NASGU>
	error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end










%--------------------------------------------------------------------------
function test_varnameNotChar( )

ncfile = 'testdata/empty.nc';
try
	nc = nc_isvar ( ncfile, 5 ); %#ok<NASGU>
	error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end














%--------------------------------------------------------------------------
function test_notNetcdfFile ()

% test 5:  not a netcdf file
try
	nc = nc_isvar ( mfilename, 't' ); %#ok<NASGU>
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end











%--------------------------------------------------------------------------
function test_emptyFile ( ncfile )

yn = nc_isvar ( ncfile, 't' );
if ( yn == 1 )
	error('incorrectly classified.');
end
return











%--------------------------------------------------------------------------
function test_dimsButNoVars ( ncfile )

yn = nc_isvar ( ncfile, 't' );
if ( yn == 1 )
	error('incorrectly classified.');
end
return













%--------------------------------------------------------------------------
function test_variableNotPresent ( ncfile )


b = nc_isvar ( ncfile, 'y' );
if ( b ~= 0 )
	error('incorrect result.');
end
return











%--------------------------------------------------------------------------
function test_variablePresent ( ncfile )



b = nc_isvar ( ncfile, 't' );
if ( b ~= 1 )
	error('incorrect result.');
end
return


%--------------------------------------------------------------------------
function test_javaNcidHttp ( )
% Ensure that NC_ISVAR works on an opened java file.

import ucar.nc2.dods.*     
import ucar.nc2.*          
                           
url = 'http://coast-enviro.er.usgs.gov/models/share/balop.nc';
jncid = NetcdfFile.open(url);

b = nc_isvar ( jncid, 'zeta' );
if ( b ~= 1 )
	error('incorrect result.');
end
close(jncid);
return
