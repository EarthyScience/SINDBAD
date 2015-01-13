function test_nc_varget( )

testroot = fileparts(mfilename('fullpath'));

fprintf('Testing NC_VARGET ...\n' );

run_nc3_tests(testroot);
run_nc4_tests(testroot);
run_nc3_java_tests(testroot);
run_nc4_java_tests(testroot);
run_grib2_java_tests(testroot);
run_opendap_tests;
run_http_tests;
run_hdf4_tests;

fprintf('OK\n');

return

%--------------------------------------------------------------------------
function test_bad_missing_value()

warning('off','SNCTOOLS:nc_varget:tmw:missingValueMismatch');
warning('off','SNCTOOLS:nc_varget:mexnc:missingValueMismatch');
nc_create_empty('foo.nc');
nc_adddim('foo.nc','x',10);
v.Name = 'y';
v.Dimension = { 'x' };
nc_addvar('foo.nc',v);
nc_attput('foo.nc','y','missing_value','1');
nc_varget('foo.nc','y');
warning('on','SNCTOOLS:nc_varget:tmw:missingValueMismatch');
warning('on','SNCTOOLS:nc_varget:mexnc:missingValueMismatch');

%--------------------------------------------------------------------------
function test_bad_fill_value()

warning('off','SNCTOOLS:nc_varget:tmw:fillValueMismatch');
warning('off','SNCTOOLS:nc_varget:mexnc:fillValueMismatch');
nc_create_empty('foo.nc');
nc_adddim('foo.nc','x',10);
v.Name = 'y';
v.Dimension = { 'x' };
nc_addvar('foo.nc',v);
nc_attput('foo.nc','y','_FillValue','1');
nc_varget('foo.nc','y');
warning('on','SNCTOOLS:nc_varget:tmw:fillValueMismatch');
warning('on','SNCTOOLS:nc_varget:mexnc:fillValueMismatch');

%--------------------------------------------------------------------------
function run_hdf4_tests()
fprintf('\tRunning HDF4 tests ...');
test_hdf4_example;
test_hdf4_scaling;
fprintf('  OK\n');


%--------------------------------------------------------------------------
function test_hdf4_example()
% test the example file that ships with matlab
exp_data = hdfread('example.hdf','Example SDS');
act_data = nc_varget('example.hdf','Example SDS');

if getpref('SNCTOOLS','PRESERVE_FVD',false)
    act_data = act_data';
end

if exp_data ~= act_data
    error('failed');
end


%--------------------------------------------------------------------------
function test_hdf4_scaling()
testroot = fileparts(mfilename('fullpath'));

oldpref = getpref('SNCTOOLS','USE_STD_HDF4_SCALING',false);

hdffile = fullfile(testroot,'testdata','temppres.hdf');

setpref('SNCTOOLS','USE_STD_HDF4_SCALING',true);
act_data = nc_varget(hdffile,'temp',[0 0],[2 2]);
exp_data = 1.8*([32 32; 33 33] - 32);

if ~getpref('SNCTOOLS','PRESERVE_FVD',false)
    act_data = act_data';
end

if exp_data ~= act_data
    error('failed');
end


setpref('SNCTOOLS','USE_STD_HDF4_SCALING',false);
act_data = nc_varget(hdffile,'temp',[0 0],[2 2]);
exp_data = 1.8*[32 32; 33 33] + 32;

if ~getpref('SNCTOOLS','PRESERVE_FVD',false)
    act_data = act_data';
end

if exp_data ~= act_data
    error('failed');
end


setpref('SNCTOOLS','USE_STD_HDF4_SCALING',oldpref);

%--------------------------------------------------------------------------
function run_opendap_tests()
if ~getpref('SNCTOOLS','TEST_REMOTE',false)
    fprintf('\tOPeNDAP testing filtered out where TEST_REMOTE ');
    fprintf(' is set to false.\n');
    return
end
if getpref('SNCTOOLS','TEST_OPENDAP',false)
	test_readOpendapVariable;

	% Regression
	test_regressionErrorMsgBadUrl;
else
	fprintf('\tOPeNDAP testing filtered out where TEST_OPENDAP ');
    fprintf('preference is set to false.\n');
end

return

%--------------------------------------------------------------------------
function run_http_tests()
	if getpref('SNCTOOLS','USE_JAVA',false) ...
            && getpref('SNCTOOLS','TEST_REMOTE',false)
		fprintf('\tRunning http/java tests...\n' );
		test_readHttpVariable;
		test_readHttpVariableGivenJavaNcid;
	else
		fprintf('\tHTTP testing filtered out where USE_JAVA and ' );
        fprintf('TEST_REMOTE preferences not both set.\n');
	end
return

%--------------------------------------------------------------------------
function run_nc3_tests(testroot)
	fprintf('\tRunning local netcdf-3 tests...' );
	ncfile = fullfile(testroot,'testdata/varget.nc');
	run_local_tests(ncfile);
    fprintf('  OK\n');
return

%--------------------------------------------------------------------------
function run_nc3_java_tests(testroot)
	switch version('-release') 
		case {'2008a', '2007b', '2007a', '2006b', '2006a', ...
                '14', '13', '12' }
			
		otherwise
			fprintf ( '\tnc3 java backend testing filtered out where ');
            fprintf ( 'the release is 2008b or higher.\n' );
			return
	end

	if ~getpref('SNCTOOLS','USE_JAVA',false)
		fprintf ( '\tnc3 java backend testing filtered out on ');
        fprintf ( 'configurations where SNCTOOLS ''USE_JAVA'' ');
        fprintf ( 'prefererence is false.\n' );
		return
	end
	fprintf('\tRunning local netcdf-3 tests with java...' );
	ncfile = fullfile(testroot,'testdata/varget.nc');
	run_local_tests(ncfile);
    fprintf('  OK\n');
return

%--------------------------------------------------------------------------
function run_nc4_java_tests(testroot)

	if ~getpref('SNCTOOLS','USE_JAVA',false)
		fprintf ( '\tjava backend testing filtered out on ');
        fprintf ( 'configurations where SNCTOOLS ''USE_JAVA'' ');
        fprintf ( 'prefererence is false.\n' );
		return
	end
	fprintf('\tRunning local netcdf-4 tests with java...' );
	ncfile = fullfile(testroot,'testdata/varget4.nc');
	run_local_tests(ncfile);

	ncfile = fullfile(testroot,'testdata/tst_pres_temp_4D_netcdf4.nc');
	% Partial Retrievals
	test_readSingleValueFromNc4File(ncfile );
	test_readFullFloatVariableNc4(ncfile);
    fprintf('  OK\n');
    

return

%--------------------------------------------------------------------------
function run_nc4_tests(testroot)
	if ~netcdf4_capable
		fprintf('\tmexnc (netcdf-4) backend testing filtered out on ');
        fprintf('configurations where the library version < 4.\n');
		return
	end
	fprintf('\tRunning local netcdf-4 tests backend...\n' );
	ncfile = fullfile(testroot,'testdata/varget4.nc');
	run_local_tests(ncfile);
return


%--------------------------------------------------------------------------
function run_local_tests(ncfile)

test_readSingleValueFrom1dVariable ( ncfile );
test_readSingleValueFrom2dVariable ( ncfile );
test_read2x2hyperslabFrom2dVariable ( ncfile );

test_readFullSingletonVariable ( ncfile );
test_readFullDoublePrecisionVariable ( ncfile );

test_readStridedVariable ( ncfile );
regression_NegSize(ncfile);
test_scaling(ncfile);

test_missing_value(ncfile);
test_bad_fill_value;
test_bad_missing_value;
return



%--------------------------------------------------------------------------
function run_grib2_java_tests(testroot)

if ~getpref('SNCTOOLS','TEST_GRIB2',false)
    fprintf('GRIB2 testing filtered out where SNCTOOLS preference ');
    fprintf('TEST_GRIB2 is set to false.\n');
    return
end
if ~getpref('SNCTOOLS','USE_JAVA',false)
    fprintf('GRIB2 testing filtered out where SNCTOOLS preference ');
    fprintf('USE_JAVA is set to false.\n');
    return
end
fprintf('\tRunning grib2 tests...');
gribfile = fullfile(testroot,'testdata',...
    'ecmf_20070122_pf_regular_ll_pt_320_pv_grid_simple.grib2');
test_readFullDouble(gribfile);
fprintf('  OK\n');
return

%--------------------------------------------------------------------------
function test_readFullDouble(gribfile)
actData = nc_varget(gribfile,'lon');
expData = 10*(0:35)';
if actData ~= expData
    error('failed');
end
return


%--------------------------------------------------------------------------
function test_readOpendapVariable ()
    % use data of today as the server has a clean up policy
    today = datestr(floor(now),'yyyymmdd');
    url = ['http://motherlode.ucar.edu:8080/thredds/dodsC/satellite/CTP/SUPER-NATIONAL_1km/current/SUPER-NATIONAL_1km_CTP_',today,'_0000.gini'];
    fprintf ( 1, 'Testing remote URL access %s...\n', url );
    
    % I have no control over what this value is, so we'll just assume it
    % is correct.
    nc_varget(url,'y',0,1);
return

%--------------------------------------------------------------------------
function test_readHttpVariable ()
    url = 'http://coast-enviro.er.usgs.gov/models/share/balop.nc';
    actData = nc_varget ( url, 'visc2' );
    expData = 20;
    if ( actData ~= expData )
        error('failed');
    end
return


%--------------------------------------------------------------------------
function test_readHttpVariableGivenJavaNcid ()
	import ucar.nc2.dods.*     
	import ucar.nc2.*          
                           
    url = 'http://coast-enviro.er.usgs.gov/models/share/balop.nc';
	jncid = NetcdfFile.open(url);
    actData = nc_varget ( url, 'visc2' );
    close(jncid);
    expData = 20;
    if ( actData ~= expData )
        error('failed');
    end
return



%==========================================================================
function test_regressionErrorMsgBadUrl ()
% Regression test.  If the URL is wrong, then the error message must give 
% name of the wrong url.   01-04-2007
% 
    url = 'http://doesntexits:8080/thredds/dodsC/nexrad/composite/1km/agg';
    try
        nc_varget ( url, 'y', 0, 1 );
    catch me
        if ~strcmp(me.identifier,'SNCTOOLS:nc_varget_java:fileOpenFailure')
            error ( 'Error id ''%s'' was not expected.', id );
        end
        if ~findstr(msg, url)
            error ( 'Error message did not contain the incorrect url.');
        end
    end
return







%--------------------------------------------------------------------------
function test_readSingleValueFrom1dVariable ( ncfile )

expData = 1.2;
actData = nc_varget ( ncfile, 'test_1D', 1, 1 );

ddiff = abs(expData - actData);
if any( find(ddiff > eps) )
    error ( 'input data ~= output data.' );
end

return








%--------------------------------------------------------------------------
function test_readSingleValueFrom2dVariable ( ncfile )

expData = 1.5;
actData = nc_varget ( ncfile, 'test_2D', [2 2], [1 1] );

ddiff = abs(expData - actData);
if any( find(ddiff > eps) )
    error('input data ~= output data.');
end

return




%--------------------------------------------------------------------------
function test_read2x2hyperslabFrom2dVariable ( ncfile )

expData = [1.5 2.1; 1.6 2.2];
if getpref('SNCTOOLS','PRESERVE_FVD',false)
    expData = expData';
end
actData = nc_varget ( ncfile, 'test_2D', [2 2], [2 2] );

if ndims(actData) ~= 2
    error ( 'rank of output data was not correct' );
end
if numel(actData) ~= 4
    error ( 'rank of output data was not correct' );
end
ddiff = abs(expData(:) - actData(:));
if any( find(ddiff > eps) )
    error ( 'input data ~= output data ' );
end

return







%--------------------------------------------------------------------------
function test_readSingleValueFromNc4File_backend_neutral ( actData )

expData = 30;
if ndims(actData) ~= 2
    error ( 'rank of output data was not correct' );
end
if numel(actData) ~= 1
    error ( 'size of output data was not correct' );
end
ddiff = abs(expData(:) - actData(:));
if any( find(ddiff > eps) )
    error ( 'input data ~= output data ' );
end

return



%--------------------------------------------------------------------
function test_readSingleValueFromNc4File ( ncfile )

switch ( version('-release') )
    case { '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
        try 
            actData = nc_varget ( ncfile, 'latitude', 1, 1 );
        catch me
            
            switch(me.identifier)
                case 'MATLAB:Java:GenericException'
                    fprintf('Could not read a NC4 file with java, you ');
                    fprintf('need >= version 4.0 of toolsUI installed.\n');
                    return
                case 'SNCTOOLS:NC_VARGET:MEXNC:OPEN'
                    fprintf('\n\n\n' );
                    fprintf('Could not read a NC4 file with mexnc, you ');
                    fprintf('would need to compile the netcdf library ');
                    fprintf('version >= version 4.0 (no, I won''t do ');
                    fprintf('that for you).\n' );
                    fprintf('\n\n\n' );
                    pause(3);
                    return
                otherwise
                    error(eid,emsg);
            end


        end
    otherwise % assume >= R2008b
	    actData = test_readSingleValueFromNc4File_tmw(ncfile);
end

if ~isempty(actData) 
	test_readSingleValueFromNc4File_backend_neutral(actData);
end
    
return








%--------------------------------------------------------------------
function test_readFullSingletonVariable ( ncfile )


expData = 3.14159;
actData = nc_varget ( ncfile, 'test_singleton' );

ddiff = abs(expData - actData);
if any( find(ddiff > eps) )
    error ( 'input data ~= output data.\n'  );
end

return



%--------------------------------------------------------------------------
function test_readFullDoublePrecisionVariable ( ncfile )


expData = 1:24;
expData = reshape(expData,6,4) / 10;

if getpref('SNCTOOLS','PRESERVE_FVD',false)
    expData = expData';
end

actData = nc_varget ( ncfile, 'test_2D' );

ddiff = abs(expData - actData);
if any( find(ddiff > eps) )
    error ( 'input data ~= output data.\n'  );
end

return




%--------------------------------------------------------------------------
function test_readFullFloatVariable_backend_neutral ( actData )

expData = [25 30 35 40 45 50];

if ndims(actData) ~= 2
    error ( 'rank of output data was not correct' );
end
if numel(actData) ~= 6
    error ( 'rank of output data was not correct' );
end
ddiff = abs(expData(:) - actData(:));
if any( find(ddiff > eps) )
    error ( 'input data ~= output data ' );
end

return



%--------------------------------------------------------------------------
function test_readFullFloatVariableNc4 ( ncfile )

if snctools_use_java
    switch ( version('-release') )
        case { 'R14', '2006a', '2006b', '2007a', '2007b', '2008a' }
            try 
                actData = nc_varget ( ncfile, 'latitude' );
            catch me
 
                if strcmp(me.identifier,'MATLAB:Java:GenericException')
                    fprintf('\tCould not read an NC4 file, make sure ');
                    fprintf('you have >= version 4.0 of toolsUI ');
                    fprintf('installed.' );
                    return
                else
                    rethrow(me);
                end


            end
        otherwise % assume >= R2008b
			actData = test_readFullFloatVariableNc4_tmw ( ncfile );
    end
    
    test_readFullFloatVariable_backend_neutral (actData);
    
end
return







%--------------------------------------------------------------------------
function test_readStridedVariable ( ncfile )

expData = 1:24;
expData = reshape(expData,6,4) / 10;
expData = expData(1:2:3,1:2:3);
if getpref('SNCTOOLS','PRESERVE_FVD',false)
    expData = expData';
end

actData = nc_varget ( ncfile, 'test_2D', [0 0], [2 2], [2 2] );

ddiff = abs(expData - actData);
if any( find(ddiff > eps) )
    error ( 'input data ~= output data.\n'  );
end

return





%--------------------------------------------------------------------------
function regression_NegSize ( ncfile )
% A negative size means to retrieve to the end along the given dimension.
expData = 1:24;
expData = reshape(expData,6,4) / 10;
sz = size(expData);
sz(2) = -1;
if getpref('SNCTOOLS','PRESERVE_FVD',false)
    expData = expData';
	sz = fliplr(sz);
end

actData = nc_varget ( ncfile, 'test_2D', [0 0], sz );

ddiff = abs(expData - actData);
if any( find(ddiff > eps) )
    error ( 'input data ~= output data.\n'  );
end

return


%--------------------------------------------------------------------------
function test_missing_value(ncfile)
% The last value should be nan.

actData = nc_varget ( ncfile, 'sst_mv' );

if ~isa(actData,'double')
    error ( 'short data was not converted to double');
end

if ~isnan( actData(end) )
    error ( 'missing value not converted to nan.\n'  );
end

return

%--------------------------------------------------------------------------
function test_scaling ( ncfile )

expData = [32 32 32 32; 50 50 50 50; 68 68 68 68; ...
           86 86 86 86; 104 104 104 104; 122 122 122 122]';

if ~getpref('SNCTOOLS','PRESERVE_FVD',false)
    expData = expData';
end
    
actData = nc_varget ( ncfile, 'temp' );

if ~isa(actData,'double')
    error ( 'short data was not converted to double');
end
ddiff = abs(expData - actData);
if any( find(ddiff > eps) )
    error ( 'input data ~= output data.\n'  );
end

return


