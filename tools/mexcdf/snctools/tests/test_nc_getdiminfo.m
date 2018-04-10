function test_nc_getdiminfo ( )
% TEST_NC_GETDIMINFO:
%
% Relies upon nc_add_dimension, nc_addvar, nc_addnewrecs


testroot = fileparts(mfilename('fullpath'));

fprintf('Testing NC_GETDIMINFO ...\n' );
test_nc3_backend (testroot);
test_nc4_backend(testroot);
fprintf('OK\n');

%--------------------------------------------------------------------------
function test_nc3_backend(testroot)
fprintf('\tRunning local netcdf-3 tests.\n');
empty_ncfile = fullfile(testroot, 'testdata/empty.nc');
full_ncfile  = fullfile(testroot, 'testdata/full.nc' );
test_local(empty_ncfile, full_ncfile);
return


%--------------------------------------------------------------------------
function test_nc4_backend(testroot)
if ~netcdf4_capable
	fprintf('\tmexnc (netcdf-4) backend testing filtered out on configurations where the library version < 4.\n');
	return
end
fprintf('\tRunning local netcdf-4 tests.\n');
empty_ncfile = fullfile(testroot, 'testdata/empty-4.nc');
full_ncfile  = fullfile(testroot, 'testdata/full-4.nc' );
test_local(empty_ncfile, full_ncfile);
return










%--------------------------------------------------------------------------
function test_local (empty_ncfile, full_ncfile )
test_neg_noArgs                                  ;
test_neg_onlyOneArg              ( empty_ncfile );
test_neg_tooManyInputs           ( empty_ncfile );
test_neg_1stArgNotNetcdfFile;
test_neg_2ndArgNotVarName                        ;
test_neg_numericArgs1stNotNcid                   ;
test_neg_numericArgs2ndNotDimid  ( full_ncfile );
test_neg_argOneCharArgTwoNumeric ( full_ncfile );
test_neg_ncidViaPackageDimDoesNotExist ( full_ncfile );
test_neg_ncidViaMexncDimDoesNotExist ( full_ncfile );
test_unlimited ( full_ncfile );
test_limited ( full_ncfile );
return






%--------------------------------------------------------------------------
function test_neg_noArgs ()
try
    nb = nc_getdiminfo; %#ok<NASGU>
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end




%--------------------------------------------------------------------------
function test_neg_onlyOneArg ( ncfile )
try
    nb = nc_getdiminfo ( ncfile ); %#ok<NASGU>
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end




%--------------------------------------------------------------------------
function test_neg_tooManyInputs ( ncfile )
try
    diminfo = nc_getdiminfo ( ncfile, 'x', 'y' ); %#ok<NASGU>
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end








%--------------------------------------------------------------------------
function test_neg_1stArgNotNetcdfFile ( )

try
    diminfo = nc_getdiminfo ( 'does_not_exist.nc', 'x' ); %#ok<NASGU>
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end






%--------------------------------------------------------------------------
function test_neg_2ndArgNotVarName ( ncfile )

try
    nc_getdiminfo ( ncfile, 'var_does_not_exist' );
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end





%--------------------------------------------------------------------------
function test_neg_numericArgs1stNotNcid ( )
try
    nc_getdiminfo ( 1, 1 );
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end




%--------------------------------------------------------------------------
function test_neg_numericArgs2ndNotDimid ( ncfile )

if snctools_use_tmw(ncfile)
	test_nc_getdiminfo_007_tmw(ncfile);

elseif snctools_use_mexnc
    [ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
    if ( status ~= 0 )
        error ( 'mexnc:open failed' );
    end
	try
    	nc_getdiminfo ( ncid, 25000 );
	catch %#ok<CTCH>
    	mexnc ( 'close', ncid );
		return
	end
	error('succeeded when it should have failed');
end

return



%--------------------------------------------------------------------------
function test_neg_argOneCharArgTwoNumeric ( ncfile )
try
    nc_getdiminfo ( ncfile, 25 );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');








%--------------------------------------------------------------------------
function test_neg_ncidViaPackageDimDoesNotExist ( ncfile )

if snctools_use_tmw(ncfile)
    ncid = netcdf.open(ncfile,nc_nowrite_mode);

    try
        nc_getdiminfo ( ncid, 'ocean_time' );
    catch %#ok<CTCH>
        netcdf.close(ncid);
        return
    end
    error('succeeded when it should have failed.');

end
return




%--------------------------------------------------------------------------
function test_neg_ncidViaMexncDimDoesNotExist ( ncfile )

if snctools_use_mexnc
    [ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
    if ( status ~= 0 )
        error('mexnc:open failed');
    end

    try
        nc_getdiminfo ( ncid, 'ocean_time' );
    catch %#ok<CTCH>
        mexnc('close',ncid);
        return
    end
    error('succeeded when it should have failed.');

end
return





%--------------------------------------------------------------------------
function test_unlimited ( ncfile )
diminfo = nc_getdiminfo ( ncfile, 't' );
if ~strcmp ( diminfo.Name, 't' )
    error('diminfo.Name was incorrect.');
end
if ( diminfo.Length ~= 0 )
    error('diminfo.Length was incorrect.');
end
if ( diminfo.Unlimited ~= 1 )
    error('diminfo.Unlimited was incorrect.');
end
return





%--------------------------------------------------------------------------
function test_limited ( ncfile )

diminfo = nc_getdiminfo ( ncfile, 's' );
if ~strcmp ( diminfo.Name, 's' )
    error('diminfo.Name was incorrect.');
end
if ( diminfo.Length ~= 1 )
    error('diminfo.Length was incorrect.');
end
if ( diminfo.Unlimited ~= 0 )
    error('diminfo.Unlimited was incorrect.');
end
return



















