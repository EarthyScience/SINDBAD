function test_snctools()
% TEST_SNCTOOLS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_snctools.m 3161 2010-06-17 09:47:50Z johnevans007 $
% $LastChangedDate: 2010-06-17 11:47:50 +0200 (qui, 17 Jun 2010) $
% $LastChangedRevision: 3161 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% switch off some warnings
mver = version('-release');
switch mver
    case {'11', '12'}
        error ('This version of MATLAB is too old, SNCTOOLS will not run.');
    case {'13'}
        error ('R13 is not supported in this release of SNCTOOLS');
    otherwise
        warning('off', 'SNCTOOLS:nc_archive_buffer:deprecated' );
        warning('off', 'SNCTOOLS:nc_datatype_string:deprecated' );
        warning('off', 'SNCTOOLS:nc_diff:deprecated' );
        warning('off', 'SNCTOOLS:nc_getall:deprecated' );
        warning('off', 'SNCTOOLS:snc2mat:deprecated' );
end


run_backend_neutral_tests;
run_backend_mex_tests;

fprintf ('\nAll  possible tests for your configuration have been ');
fprintf ('run.  Bye.\n\n' );

warning('on', 'SNCTOOLS:nc_archive_buffer:deprecated' );
warning('on', 'SNCTOOLS:nc_datatype_string:deprecated' );
warning('on', 'SNCTOOLS:nc_diff:deprecated' );
warning('on', 'SNCTOOLS:nc_getall:deprecated' );
warning('on', 'SNCTOOLS:snc2mat:deprecated' );
        
return










%----------------------------------------------------------------------
function run_backend_neutral_tests()

test_nc_attget;
test_nc_datatype_string;
test_nc_iscoordvar;
test_nc_isunlimitedvar;
test_nc_dump;
test_nc_getlast;
test_nc_isvar;
test_nc_varsize;
test_nc_getvarinfo;
test_nc_info;
test_nc_getbuffer;
test_nc_varget;
test_nc_getdiminfo;


return




%----------------------------------------------------------------------
function run_backend_mex_tests()

if ~(snctools_use_tmw || snctools_use_mexnc)
	fprintf('Cannot use native netcdf support or mexnc, no tests ');
    fprintf('requiring netcdf output can be run.\n' );	
	return
end

test_nc_varput;
test_nc_adddim           ( 'test.nc' );
test_nc_addhist          ( 'test.nc' );
test_nc_addvar           ( 'test.nc' );
test_nc_attput           ( 'test.nc' );
test_nc_create_empty     ( 'test.nc' );
test_nc_varrename        ( 'test.nc' );
test_nc_addnewrecs       ( 'test.nc' );
test_nc_addrecs          ( 'test.nc' );


test_snc2mat             ( 'test.nc' );
test_nc_getall           ( 'test.nc' );
evalc('test_nc_diff(''test1.nc'',''test2.nc'');');
test_nc_cat_a;
test_nc_cat;


return

