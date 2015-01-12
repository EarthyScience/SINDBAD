function dinfo = nc_getdiminfo_hdf5 ( arg1, arg2 )

if ischar(arg1) && ischar(arg2)
    dinfo = handle_char_nc_getdiminfo_hdf5(arg1,arg2);
elseif isnumeric ( arg1 ) && isnumeric ( arg2 )
	dinfo = handle_numeric_nc_getdiminfo_hdf5(arg1,arg2);
else
	error ( 'SNCTOOLS:NC_GETDIMINFO_HDF5:badInputDatatypes', ...
	            'Must supply either two character or two numeric arguments.' );
end



return



%------------------------------------------------------------------------------
function dinfo = handle_char_nc_getdiminfo_hdf5 ( ncfile, dimname )

file_id = H5F.open(ncfile,'H5F_ACC_RDONLY','H5P_DEFAULT');
dset_id = H5D.open(file_id,dimname);

if ~H5DS.is_scale(dset_id)
	H5D.close(dset_id);
	H5F.close(file_id);

	error ( 'SNCTOOLS:NC_GETDIMINFO_HDF5:notDimensions', ...
	        '%s is not a dimension.', dimname );
end

try
	dinfo = handle_numeric_nc_getdiminfo_hdf5 ( file_id,  dset_id );
catch me
	H5D.close(dset_id);
	H5F.close(file_id);
	rethrow(me);
end

H5D.close(dset_id);
H5F.close(file_id);




%------------------------------------------------------------------------------
function dinfo = handle_numeric_nc_getdiminfo_hdf5 ( file_id, dset_id )

space_id = H5D.get_space(dset_id);
[numdims, h5_dims h5_maxdims] = H5S.get_simple_extent_dims(space_id);
if numdims ~= 1
	H5S.close(space_id);
	error('SNCTOOLS:NC_GETDIMINFO:dimensionScaleNot1D', ...
	      'The dimension scale is not one-dimensional.');
end

dinfo.Name = H5I.get_name(dset_id);
% strip any leading '/'
if dinfo.Name(1) == '/'
	dinfo.Name = dinfo.Name(2:end);
end
dinfo.Length = H5S.get_simple_extent_npoints(space_id);

if h5_maxdims == -1
	dinfo.Unlimited = true;
else
	dinfo.Unlimited = false;
end

H5S.close(space_id);

return

