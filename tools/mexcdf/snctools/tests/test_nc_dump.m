function test_nc_dump ( )
% TEST_NC_DUMP:  runs series of tests for nc_dump.m
%
% Relies upon nc_add_dimension, nc_addvar, nc_attput
%
%

fprintf('Testing NC_DUMP ...' );

% For now we will run this test preserving the fastest varying dimension.
oldpref = getpref('SNCTOOLS','PRESERVE_FVD');
setpref('SNCTOOLS','PRESERVE_FVD',true);

testroot = fileparts(mfilename('fullpath'));

negative_no_arguments;

empty_file                        (fullfile(testroot,'testdata/empty.nc' ));
file_with_one_dimension           (fullfile(testroot,'testdata/just_one_dimension.nc' ));
file_with_one_fixed_size_variable (fullfile(testroot,'testdata/just_one_fixed_size_variable.nc' ));
variable_attributes               (fullfile(testroot,'testdata/full.nc' ));
unlimited_variable                (fullfile(testroot,'testdata/full.nc' ));
singleton_variable                (fullfile(testroot,'testdata/full.nc' ));
nc4file                           (fullfile(testroot,'testdata/tst_pres_temp_4D_netcdf4.nc' ));

run_hdf4_tests;
run_java_tests;
test_opendap_url;

setpref('SNCTOOLS','PRESERVE_FVD',oldpref);
fprintf('OK\n');
return





%--------------------------------------------------------------------------
function run_hdf4_tests()
dump_hdf4_example;
dump_hdf4_tp;


%--------------------------------------------------------------------------
function dump_hdf4_example()
% dumps the example file that ships with matlab
testroot = fileparts(mfilename('fullpath'));
matfile = fullfile(testroot,'testdata','nc_dump.mat');
load(matfile);

act_data = evalc('nc_dump(''example.hdf'');');
i1 = strfind(act_data,'{');
i2 = strfind(d.hdf4.example,'{');

if ~strcmp(d.hdf4.example(i2:end), act_data(i1:end))
    error('failed');
end
%--------------------------------------------------------------------------
function dump_hdf4_tp()
% dumps my temperature pressure file
testroot = fileparts(mfilename('fullpath'));
matfile = fullfile(testroot,'testdata','nc_dump.mat');
load(matfile);
hdffile = fullfile(testroot,'testdata','temppres.hdf'); %#ok<NASGU>

act_data = evalc('nc_dump(hdffile);');
i1 = strfind(act_data,'{');
i2 = strfind(d.hdf4.temppres,'{');
if ~strcmp(d.hdf4.temppres(i2:end), act_data(i1:end))
    error('failed');
end

%-------------------------------------------------------------------------
function run_java_tests()

if ~getpref('SNCTOOLS','USE_JAVA',false)
    fprintf('Java testing filtered out where SNCTOOLS preference ');
    fprintf('USE_JAVA is set to false.\n');
    return
end

test_http_non_dods;
test_grib2;
return






%--------------------------------------------------------------------------
function test_grib2()

if ~getpref('SNCTOOLS','TEST_GRIB2',false)
    fprintf('GRIB2 testing filtered out where SNCTOOLS preference ');
    fprintf('TEST_GRIB2 is set to false.\n');
    return
end

% Test a GRIB2 file.  Requires java as far as I know.
testroot = fileparts(mfilename('fullpath'));
matfile = fullfile(testroot,'testdata','nc_dump.mat');
load(matfile);
gribfile = fullfile(testroot,'testdata',...
    'ecmf_20070122_pf_regular_ll_pt_320_pv_grid_simple.grib2'); %#ok<NASGU>
act_data = evalc('nc_dump(gribfile);'); %#ok<NASGU>

% So long as it didn't error out, I'm cool with that.
return






%--------------------------------------------------------------------------
function test_opendap_url (  )
if getpref('SNCTOOLS','TEST_REMOTE',false) && ...
        getpref ( 'SNCTOOLS', 'TEST_OPENDAP', false ) 
    % use data of today as the server has a clean up policy
    today = datestr(floor(now),'yyyymmdd');
    url = ['http://motherlode.ucar.edu:8080/thredds/dodsC/satellite/CTP/SUPER-NATIONAL_1km/current/SUPER-NATIONAL_1km_CTP_',today,'_0000.gini'];
	fprintf('Testing remote DODS access %s...\n', url );
	nc_dump(url);
else
	fprintf('Not testing NC_DUMP on OPeNDAP URLs.  Read the README for details.\n');	
end
return

function test_http_non_dods (  )
if (getpref ( 'SNCTOOLS', 'USE_JAVA', false)  && ...
    getpref ( 'SNCTOOLS', 'TEST_REMOTE', false)  )
	url = 'http://coast-enviro.er.usgs.gov/models/share/balop.nc';
	fprintf ( 1, 'Testing remote URL access %s...\n', url );
	nc_dump ( url );
end




%--------------------------------------------------------------------------
function negative_no_arguments ( )
% should fail if no input arguments are given.

try
	nc_dump;
catch %#ok<CTCH>
	return
end
error ( 'nc_dump succeeded when it should have failed.');










%--------------------------------------------------------------------------
function empty_file ( ncfile ) %#ok<INUSD>

load('testdata/nc_dump.mat');
act_data = evalc('nc_dump(ncfile);');
i1 = strfind(act_data,'{');
i2 = strfind(d.netcdf.empty_file,'{');
if ~strcmp(act_data(i1:end),d.netcdf.empty_file(i2:end))
    error('failed');
end

return







%--------------------------------------------------------------------------
function file_with_one_dimension ( ncfile ) %#ok<INUSD>
load('testdata/nc_dump.mat');
act_data = evalc('nc_dump(ncfile);');
i1 = strfind(act_data,'{');
i2 = strfind(d.netcdf.one_dimension,'{');
if ~strcmp(act_data(i1:end),d.netcdf.one_dimension(i2:end))
    error('failed');
end
return




%--------------------------------------------------------------------------
function file_with_one_fixed_size_variable ( ncfile ) %#ok<INUSD>

load('testdata/nc_dump.mat');
act_data = evalc('nc_dump(ncfile);');
i1 = strfind(act_data,'{');
i2 = strfind(d.netcdf.one_fixed_size_variable,'{');
if ~strcmp(act_data(i1:end),d.netcdf.one_fixed_size_variable(i2:end))
    error('failed');
end
return




%--------------------------------------------------------------------------
function variable_attributes ( ncfile ) %#ok<INUSD>
load('testdata/nc_dump.mat');
act_data = evalc('nc_dump(ncfile);');
i1 = strfind(act_data,'{');
i2 = strfind(d.netcdf.variable_attributes,'{');
if ~strcmp(act_data(i1:end),d.netcdf.variable_attributes(i2:end))
    error('failed');
end
return



%--------------------------------------------------------------------------
function unlimited_variable ( ncfile ) %#ok<INUSD>
load('testdata/nc_dump.mat');
act_data = evalc('nc_dump(ncfile);');
i1 = strfind(act_data,'{');
i2 = strfind(d.netcdf.unlimited_variable,'{');
if ~strcmp(act_data(i1:end),d.netcdf.unlimited_variable(i2:end))
    error('failed');
end

return









%--------------------------------------------------------------------------
function singleton_variable ( ncfile ) %#ok<INUSD>
load('testdata/nc_dump.mat');
act_data = evalc('nc_dump(ncfile);');
i1 = strfind(act_data,'{');
i2 = strfind(d.netcdf.singleton_variable,'{');
if ~strcmp(act_data(i1:end),d.netcdf.singleton_variable(i2:end))
    error('failed');
end
return






%--------------------------------------------------------------------------
function nc4file ( ncfile ) %#ok<INUSD>
load('testdata/nc_dump.mat');
try
    act_data = evalc('nc_dump(ncfile);');
    if ~strcmp(act_data,d.netcdf.netcdf4)
        error('failed');
    end
catch %#ok<CTCH>
    [msg,eid] = lasterr; %#ok<LERR,ASGLU>
    switch ( eid )
        case 'SNCTOOLS:nc_info:javaRetrievalMethodNotAvailable'
            return
        case 'MATLAB:netcdf:open:notANetcdfFile'
            return
    end
end

return











