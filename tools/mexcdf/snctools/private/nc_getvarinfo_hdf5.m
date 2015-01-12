function info = nc_getvarinfo_hdf5 ( arg1, arg2 )
% Retrieve the INFO struct for a netCDF variable when the netCDF file is
% netCDF-4.

close_it = false;
if ischar(arg1) && ischar(arg2)
	% We were given a char filename and a char varname.

	ncfile = arg1;
	varname = arg2;

	file_id = H5F.open(ncfile,'H5F_ACC_RDONLY','H5P_DEFAULT');
	dset_id = H5D.open(file_id,varname);
    
    close_it = true;

elseif isnumeric ( arg1 ) && isnumeric ( arg2 )  
    
    file_id = arg1;
    dset_id = arg2;
    
else
 
    error('SNCTOOLS:nc_getvarinfo_hdf5:badInput', ...
          'Ipput arguments must both be char or both be numeric.' );    
end


if ~just_a_dimscale(dset_id)

    vname = H5I.get_name(dset_id);
    if vname(1) == '/'
    	vname = vname(2:end);
    end
    info.Name = vname;
    
    info.Nctype = get_nc_datatype_hdf5(H5D.get_type(dset_id));
    
    
    space_id = H5D.get_space(dset_id);
    [ndims,hsize,hmaxsize] = H5S.get_simple_extent_dims(space_id);
    
    if any(hmaxsize == -1)
        info.Unlimited = true;
    else
        info.Unlimited = false;
    end
    
    if H5DS.is_scale(dset_id)
        Dimensions = { vname };
    else
        Dimensions = cell(0);
        for j = 1:ndims
            [~, ~, Dimensions{j}] = H5DS.iterate_scales(dset_id,j-1,0,@get_scale_info,'');
        end
    end
    info.Dimension = Dimensions;
    
    H5S.close(space_id);
    
    info.Size = hsize;
    info.Attribute = get_h5nc4_attributes(dset_id);

else
	if close_it
		H5D.close(dset_id);
		H5F.close(file_id);
	end    
    error('SNCTOOLS:nc_getvarinfo_hdf5:isDimScaleButNotVar', ...
        '%s is a dimension scale but not a variable.', ...
        H5I.get_name(dset_id));
end

    

if close_it
	H5D.close(dset_id);
	H5F.close(file_id);
end    
return




%--------------------------------------------------------------------------
function bool = just_a_dimscale(dset_id)
% We need to know if this HDF5 dataset is just a dimension scale and not a 
% netCDF coordinate variable.

bool = false;

if H5DS.is_scale(dset_id)
	% It could be a coordinate variable.  HDF5 variables that are just 
	% netcdf dimensions seem to have an attribute called NAME
	% that has the string "This is a netCDF dimension but not a netCDF variable."
	try
		attr_id = H5A.open_name(dset_id,'NAME');
		name = H5A.read(attr_id,'H5ML_DEFAULT');
		if strncmp(name,'This is a netCDF dimension but not a netCDF variable.',53)
			bool = true;
		end
		H5A.close(attr_id);
	catch me
		me
	end
end

return




%-------------------------------------------------------------------------------
function [status, opdata_out] = get_scale_info(~,~,dimscale_id,~)
	status = 0;
	opdata_out = [];
	try
		scale_name = H5I.get_name(dimscale_id);
		if scale_name(1) == '/'
			scale_name = scale_name(2:end);
		end
		opdata_out = scale_name;
	catch me
		status = -1;
	end
return




