function test_nc_getvarinfo ( )

fprintf('Testing NC_GETVARINFO...\n' );
run_local_tests;
run_http_tests;
return



function run_local_tests()

testroot = fileparts(mfilename('fullpath'));

fprintf('\tRunning local tests...\n');
test_noInputs                                   ;
test_tooFewInputs                     (testroot);
test_tooManyInput                     (testroot);
test_fileIsNotNetcdfFile                        ;
test_varIsNotNetcdfVariable           (testroot);
test_fileIsNumeric_varIsChar                    ;
test_fileIsChar_varIsNumeric          (testroot);
			              
test_limitedVariable                  (testroot);
test_unlimitedVariable                (testroot);
test_unlimitedVariableWithOneAttribute(testroot);

return




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
	fprintf('\tRunning http/java tests...\n');
	test_fileIsHttpUrl_varIsChar;
	test_fileIsJavaNcid_varIsChar;
return






%--------------------------------------------------------------------------
function test_noInputs ()


try
	nc_getvarinfo;
catch %#ok<CTCH>
    return
end
error('failed');








%--------------------------------------------------------------------------
function test_tooFewInputs (testroot)
ncfile = fullfile(testroot,'testdata/full.nc');

try
	nc_getvarinfo ( ncfile );
catch %#ok<CTCH>
    return
end
error('failed');







%--------------------------------------------------------------------------
function test_tooManyInput (testroot)
ncfile = fullfile(testroot,'testdata/full.nc');
try
	nc_getvarinfo ( ncfile, 't1' );
catch %#ok<CTCH>
    return
end
error('failed');









%--------------------------------------------------------------------------
function test_fileIsNotNetcdfFile ()


try
	nc_getvarinfo ( 'iamnotarealfilenoreally', 't1' );
catch %#ok<CTCH>
    return
end
error('failed');















%--------------------------------------------------------------------------
function test_varIsNotNetcdfVariable (testroot)

ncfile = fullfile(testroot,'testdata/full.nc');
try
	nc_getvarinfo ( ncfile, 't5' );
catch %#ok<CTCH>
    return
end
error('failed');










%--------------------------------------------------------------------------
function test_fileIsNumeric_varIsChar ()

try
	nc_getvarinfo ( 0, 't1' );
catch %#ok<CTCH>
    return
end
error('failed');




%--------------------------------------------------------------------------
function test_fileIsJavaNcid_varIsChar ( )

import ucar.nc2.dods.*     
import ucar.nc2.*          

url = 'http://rocky.umeoce.maine.edu/GoMPOM/cdfs/gomoos.20070723.cdf';
jncid = NetcdfFile.open(url);

try
	nc_getvarinfo ( jncid, 'w' );
catch %#ok<CTCH>
    error('failed');
end





%--------------------------------------------------------------------------
function test_fileIsHttpUrl_varIsChar ( )

import ucar.nc2.dods.*     
import ucar.nc2.*          

url = 'http://rocky.umeoce.maine.edu/GoMPOM/cdfs/gomoos.20070723.cdf';

try
	nc_getvarinfo ( url, 'w' );
catch %#ok<CTCH>
    error('failed');
end




%--------------------------------------------------------------------------
function test_fileIsChar_varIsNumeric (testroot)
ncfile = fullfile(testroot,'testdata/full.nc');
try
	nc_getvarinfo ( ncfile, 0 );
catch %#ok<CTCH>
    return
end
error('failed');





%--------------------------------------------------------------------------
function test_limitedVariable (testroot)
ncfile = fullfile(testroot,'testdata/getlast.nc');
v = nc_getvarinfo ( ncfile, 'x' );

if ~strcmp(v.Name, 'x' )
    error('failed');
end
if (v.Nctype~=6 )
    error('failed');
end
if (v.Unlimited~=0 )
    error('failed');
end
if (length(v.Dimension)~=1 )
    error('failed');
end
if ( ~strcmp(v.Dimension{1},'x') )
    error('failed');
end
if (v.Size~=2 )
    error('failed');
end
if (numel(v.Size)~=1 )
    error('failed');
end
if (~isempty(v.Attribute) )
    error('failed');
end

return





%--------------------------------------------------------------------------
function test_unlimitedVariable (testroot)
ncfile = fullfile(testroot,'testdata/getlast.nc');

v = nc_getvarinfo ( ncfile, 't1' );

if ~strcmp(v.Name, 't1' )
    error('failed');
end
if (v.Nctype~=6 )
    error('failed');
end
if (v.Unlimited~=1 )
    error('failed');
end
if (length(v.Dimension)~=1 )
    error('failed');
end
if (v.Size~=10 )
    error('failed');
end
if (numel(v.Size)~=1 )
    error('failed');
end
if (~isempty(v.Attribute) )
    error('failed');
end

return







%--------------------------------------------------------------------------
function test_unlimitedVariableWithOneAttribute (testroot)

ncfile = fullfile(testroot,'testdata/getlast.nc');
v = nc_getvarinfo ( ncfile, 't4' );

if ~strcmp(v.Name, 't4' )
	error('Name was not correct.');

end
if (v.Nctype~=6 )
	error('Nctype was not correct.');
end
if (v.Unlimited~=1 )
    error('Unlimited was not correct.');
end
if (length(v.Dimension)~=2 )
	error('Dimension was not correct.');
end
if (numel(v.Size)~=2 )
	error( 'Rank was not correct.');
end
if (length(v.Attribute)~=1 )
	error('Attribute was not correct.');
end

return

