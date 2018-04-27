function atts = get_h5nc4_attributes(obj_id)
atts = [];
total_attrs = H5A.get_num_attrs(obj_id);
if total_attrs == 0
    return;
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



