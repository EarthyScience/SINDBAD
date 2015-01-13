function test_snc2mat ( ncfile )
% TEST_SNC2MAT
% Relies upon nc_varput, nc_add_dimension, nc_addvar
%
% Tests
% Test 1:  netcdf file does not exist.
% Test 2:  try a pretty generic netcdf file

if nargin == 0
	ncfile = 'foo.nc';
end


fprintf ('Testing SNC2MAT ...' );


test_generic_file ( ncfile );
test_file_does_not_exist ( ncfile );
fprintf ('OK\n');

return










%--------------------------------------------------------------------------
function test_file_does_not_exist ( ncfile )

v = version('-release');
switch(v)
	case{'14','2006a','2006b','2007a'}
		% These versions can't do try/catch.
	    return
end

% netcdf file does not exist.
matfile_name = [ ncfile '.mat' ];
try
	snc2mat ( 'bad.nc', matfile_name );
catch me %#ok<NASGU>
    %  'MATLAB:netcdf:open:noSuchFile'
    return
end




%--------------------------------------------------------------------------
function test_generic_file( ncfile )

create_empty_file ( ncfile );
len_x = 4; len_y = 6;
nc_add_dimension ( ncfile, 'x', len_x );
nc_add_dimension ( ncfile, 'y', len_y );

clear varstruct;
varstruct.Name = 'z_double';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'y', 'x' };
nc_addvar ( ncfile, varstruct );




input_data = 1:1:len_y*len_x;
input_data = reshape ( input_data, len_y, len_x );

nc_varput ( ncfile, 'z_double', input_data );



matfile_name = [ ncfile '.mat' ];
snc2mat ( ncfile, matfile_name );


%
% now check it
d = load ( matfile_name );
output_data = d.z_double.data;



d = max(abs(output_data-input_data))';
if (any(d))
	error ( 'failed' );
end
return











