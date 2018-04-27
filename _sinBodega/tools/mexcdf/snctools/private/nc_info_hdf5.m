function fileinfo = nc_info_hdf5 ( ncfile )
% Private function for gathering info struct via HDF5 backend.

fileinfo.Filename = ncfile;

file_id = H5F.open(ncfile,'H5F_ACC_RDONLY','H5P_DEFAULT');
gid = H5G.open(file_id,'/');

opdata_in.ncfile = ncfile;
opdata_in.Dataset = [];

[status, idx_out, opdata_out] = H5L.iterate(gid,'H5_INDEX_CRT_ORDER','H5_ITER_INC',0,@iter_h5nc4_vars,opdata_in); 
if status ~= 0
	H5G.close(gid);
	H5F.close(file_id);
	error('SNCTOOLS:nc_info:varIterationFailed', ...
	      'Link iteration failed on netcdf-4 variables.' );
	
end
fileinfo.Dataset = opdata_out.Dataset;

clear opdata_in;
opdata_in.ncfile = ncfile;
opdata_in.Dimension = [];
[status, idx_out, opdata_out] = H5L.iterate(gid,'H5_INDEX_CRT_ORDER','H5_ITER_INC',0,@iter_h5nc4_dims,opdata_in); 
if status ~= 0
	H5G.close(gid);
	H5F.close(file_id);
	error('SNCTOOLS:nc_info:dimensionIterationFailed', ...
	      'Link iteration failed on netcdf-4 dimensions.' );
	
end
fileinfo.Dimension = opdata_out.Dimension;

fileinfo.Attribute = get_h5nc4_attributes(gid);

H5G.close(gid);
H5F.close(file_id);

%--------------------------------------------------------------------------
function [status, opdata_out] = iter_h5nc4_dims(gid,name,opdata_in)
status = 0;
opdata_out = opdata_in;

try
	dset_id = H5D.open(gid,name);
	if H5DS.is_scale(dset_id)
		space_id = H5D.get_space(dset_id);
		[n,dims,maxdims] = H5S.get_simple_extent_dims(space_id);
		H5S.close(space_id);
	
		Dimension.Name = name;
		Dimension.Length = dims;
		Dimension.Unlimited = any(maxdims == -1);
		
		if numel(opdata_out.Dimension) == 0
			opdata_out.Dimension = Dimension;
		else
			opdata_out.Dimension(end+1) = Dimension;
		end
	end
	
	H5D.close(dset_id);
	
catch me
	me
	status = -1;
end



return
%--------------------------------------------------------------------------
function [status, opdata_out] = iter_h5nc4_vars(gid,name,opdata_in)
status = 0;
opdata_out = opdata_in;

%fprintf('iterating over %s\n', name );
try
	info = nc_getvarinfo(opdata_in.ncfile,name);
    if numel(opdata_out.Dataset) == 0
        opdata_out.Dataset = info;
    else
        opdata_out.Dataset(end+1) = info;
    end
catch me
	if strcmp(me.identifier,'SNCTOOLS:nc_getvarinfo_hdf5:isDimScaleButNotVar')
		%fprintf('%s is a dimension scale, but not a varible, skipping...\n', name );
		return
	else
		status = -1;
    end
end


return



%--------------------------------------------------------------------------
function atts = get_h5nc4_attributes(obj_id)
atts = [];
total_attrs = H5A.get_num_attrs(obj_id);
if total_attrs == 0
    return
end

count = 0;
for j = 0:total_attrs-1
    attr_id = H5A.open_idx(obj_id,j);
	name = H5A.get_name(attr_id);

	% Some attributes are netcdf-4-internals.  Skip them.
    switch ( name )
        case { 'DIMENSION_LIST', 'CLASS', 'NAME', 'REFERENCE_LIST' }
            H5A.close(attr_id);
            continue
        
        otherwise
            count = count + 1;
    end

	value = H5A.read(attr_id,'H5ML_DEFAULT');

	atts(count,1).Name = name; %#ok<AGROW>
	if ischar(value)
		atts(count,1).Value = value'; %#ok<AGROW>
	else
		atts(count,1).Value = value; %#ok<AGROW>
	end
	atts(count,1).Nctype = get_nc_datatype_hdf5(H5A.get_type(attr_id));
    H5A.close(attr_id);
end
return



