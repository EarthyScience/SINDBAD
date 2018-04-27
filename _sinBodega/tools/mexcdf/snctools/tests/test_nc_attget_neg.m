function test_nc_attget_neg()

global ignore_eids;
ignore_eids = getpref('SNCTOOLS','IGNOREEIDS',true);

testroot = fileparts(mfilename('fullpath'));

run_nc3_tests     (testroot);
run_nc4_tests     (testroot);
run_nc4_java_tests(testroot);

%--------------------------------------------------------------------------
function run_nc3_tests(testroot)
	ncfile = fullfile(testroot,'testdata/attget.nc');
	run_local_tests(ncfile);
return

%--------------------------------------------------------------------------
function run_nc4_tests(testroot)
	if getpref('SNCTOOLS','USE_JAVA',false)
		return
	end
	if ~netcdf4_capable
		return
	end
	ncfile = fullfile(testroot,'testdata/attget-4.nc');
	run_local_tests(ncfile);
return

%--------------------------------------------------------------------------
function run_nc4_java_tests(testroot)
	if ~getpref('SNCTOOLS','USE_JAVA',false)
		return
	end
	ncfile = fullfile(testroot,'testdata/attget-4.nc');
	run_local_tests(ncfile);
return


%--------------------------------------------------------------------------
function run_local_tests(ncfile)

test_retrieveNonExistingAttribute ( ncfile );

return;







%--------------------------------------------------------------------------
function test_retrieveNonExistingAttribute ( ncfile )

global ignore_eids;

try
	nc_attget ( ncfile, 'z_double', 'test_double_att' );
catch me
    if ignore_eids
        return
    end
    switch(me.identifier)
        case { 'MATLAB:netcdf:inqAtt:attributeNotFound', ...
                'SNCTOOLS:NC_ATTGET:MEXNC:INQ_ATTTYPE', ...
                'SNCTOOLS:attget:java:attributeNotFound'}
            return
        otherwise
            rethrow(me);
    end
                
end
error('failed');










