function test_nc_attget ( )

fprintf ('Testing NC_ATTGET...\n' );

v = version('-release');
switch(v)
	case{'14','2006a','2006b'}
	    fprintf('\tSome negative tests filtered out on version %s.\n', v);
    otherwise
		test_nc_attget_neg;
end

testroot = fileparts(mfilename('fullpath'));

run_nc3_tests     (testroot);
run_nc4_tests     (testroot);
run_nc4_java_tests(testroot);
run_java_tests    (testroot);


fprintf('OK\n');


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
act_data = nc_attget(gribfile,-1,'creator_name');
exp_data = 'ECMWF, RSMC subcenter = 0';
if ~strcmp(act_data,exp_data)
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

test_retrieveDoubleAttribute ( ncfile );
test_retrieveFloatAttribute ( ncfile );
test_retrieveIntAttribute ( ncfile );
test_retrieveShortAttribute ( ncfile );
test_retrieveUint8Attribute ( ncfile );
test_retrieveInt8Attribute ( ncfile );
test_retrieveTextAttribute ( ncfile );

test_retrieveGlobalAttribute_empty ( ncfile );
test_writeRetrieveGlobalAttributeMinusOne ( ncfile );
test_writeRetrieveGlobalAttributeNcGlobal ( ncfile );
test_writeRetrieveGlobalAttributeGlobalName ( ncfile );


return;


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
	test_retrieveAttribute_HTTP;
	test_retrieveAttribute_http_jncid;
return







%--------------------------------------------------------------------------
function test_retrieveAttribute_HTTP ()

url = 'http://rocky.umeoce.maine.edu/GoMPOM/cdfs/gomoos.20070723.cdf';

w = nc_attget ( url, 'w', 'valid_range' );
if ~strcmp(class(w),'single')
	error ( 'Class of retrieve attribute was not single' );
end
if (abs(double(w(2)) - 0.5) > eps)
	error ( 'valid max did not match' );
end
if (abs(double(w(1)) + 0.5) > eps)
	error ( 'valid max did not match' );
end
return


%--------------------------------------------------------------------------
function test_retrieveAttribute_http_jncid ()

import ucar.nc2.dods.*     
import ucar.nc2.*          

url = 'http://rocky.umeoce.maine.edu/GoMPOM/cdfs/gomoos.20070723.cdf';
jncid = NetcdfFile.open(url);
                           

w = nc_attget (jncid, 'w', 'valid_range' );
if ~strcmp(class(w),'single')
	error ( 'Class of retrieve attribute was not single' );
end
if (abs(double(w(2)) - 0.5) > eps)
	error ( 'valid max did not match' );
end
if (abs(double(w(1)) + 0.5) > eps)
	error ( 'valid max did not match' );
end
close(jncid);
return


%--------------------------------------------------------------------------
function test_retrieveIntAttribute ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_int_att' );
if ( ~strcmp(class(attvalue), 'int32' ) )
	error('class of retrieved attribute was not int32.');
end
if ( attvalue ~= int32(3) )
	error('retrieved attribute differs from what was written.');
end

return










%--------------------------------------------------------------------------
function test_retrieveShortAttribute ( ncfile )


attvalue = nc_attget ( ncfile, 'x_db', 'test_short_att' );
if ( ~strcmp(class(attvalue), 'int16' ) )
	error('class of retrieved attribute was not int16.');
end
if ( length(attvalue) ~= 2 )
	error('retrieved attribute length differs from what was written.');
end
if ( any(double(attvalue) - [5 7])  )
	error('retrieved attribute differs from what was written.');
end

return








%--------------------------------------------------------------------------
function test_retrieveUint8Attribute ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_uchar_att' );
if ( ~strcmp(class(attvalue), 'int8' ) )
	error('class of retrieved attribute was not int8.');
end
if ( uint8(attvalue) ~= uint8(100) )
	error('retrieved attribute differs from what was written.');
end

return




%--------------------------------------------------------------------------
function test_retrieveInt8Attribute ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_schar_att' );
if ( ~strcmp(class(attvalue), 'int8' ) )
	error('class of retrieved attribute was not int8.');
end
if ( attvalue ~= int8(-100) )
	error('retrieved attribute differs from what was written.');
end

return







%--------------------------------------------------------------------------
function test_retrieveTextAttribute ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_text_att' );
if ( ~ischar(attvalue ) )
	error('class of retrieved attribute was not char.');
end

if ( ~strcmp(attvalue,'abcdefghijklmnopqrstuvwxyz') )
	error('retrieved attribute differs from what was written.');
end

return







%--------------------------------------------------------------------------
function test_retrieveGlobalAttribute_empty ( ncfile )

warning ( 'off', 'SNCTOOLS:nc_attget:java:doNotUseGlobalString' );
warning ( 'off', 'SNCTOOLS:nc_attget:hdf5:doNotUseEmptyVarname' );
warning ( 'off', 'SNCTOOLS:nc_attget:hdf5:doNotUseGlobalVarname' );

attvalue = nc_attget ( ncfile, '', 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	error('class of retrieved attribute was not double.');
end
if ( attvalue ~= 3.14159 )
	error('retrieved attribute differs from what was written.');
end

warning ( 'on', 'SNCTOOLS:nc_attget:java:doNotUseGlobalString' );
warning ( 'off', 'SNCTOOLS:nc_attget:hdf5:doNotUseEmptyVarname' );
warning ( 'off', 'SNCTOOLS:nc_attget:hdf5:doNotUseGlobalVarname' );

return





%--------------------------------------------------------------------------
function test_writeRetrieveGlobalAttributeMinusOne ( ncfile )

attvalue = nc_attget ( ncfile, -1, 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	error('class of retrieved attribute was not double.');
end
if ( attvalue ~= 3.14159 )
	error('retrieved attribute differs from what was written.');
end

return





%--------------------------------------------------------------------------
function test_writeRetrieveGlobalAttributeNcGlobal ( ncfile )

attvalue = nc_attget ( ncfile, nc_global, 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	error('class of retrieved attribute was not double.');
end
if ( attvalue ~= 3.14159 )
	error('retrieved attribute differs from what was written.');
end

return 






%--------------------------------------------------------------------------
function test_writeRetrieveGlobalAttributeGlobalName ( ncfile )

warning ( 'off', 'SNCTOOLS:nc_attget:doNotUseGlobalString' );
warning ( 'off', 'SNCTOOLS:nc_attget:java:doNotUseGlobalString' );

attvalue = nc_attget ( ncfile, 'GLOBAL', 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	error('class of retrieved attribute was not double.');
end
if ( attvalue ~= 3.14159 )
	error('retrieved attribute differs from what was written.');
end

warning ( 'on', 'SNCTOOLS:nc_attget:java:doNotUseGlobalString' );
warning ( 'on', 'SNCTOOLS:nc_attget:doNotUseGlobalString' );

return
















%--------------------------------------------------------------------------
function test_retrieveDoubleAttribute ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	error('class of retrieved attribute was not double.');
end
if ( attvalue ~= 3.14159 )
	error('retrieved attribute differs from what was written.');
end

return







%--------------------------------------------------------------------------
function test_retrieveFloatAttribute ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_float_att' );
if ( ~strcmp(class(attvalue), 'single' ) )
	error('class of retrieved attribute was not single.');
end
if ( abs(double(attvalue) - 3.14159) > 1e-6 )
	error('retrieved attribute differs from what was written.');
end

return


