function Dataset = get_varinfo_tmw ( ncid, varid )


[ndims,nvars,ngatts,record_dimension] = netcdf.inq(ncid); %#ok<ASGLU>
[varname,datatype,dims,natts] = netcdf.inqVar(ncid, varid);
ndims = numel(dims);

Dataset.Name = varname;
Dataset.Nctype = datatype;
switch(datatype)
    case nc_nat
        Dataset.Datatype = '';
    case nc_byte
        Dataset.Datatype = 'int8';
    case nc_char
        Dataset.Datatype = 'char';
    case nc_short
        Dataset.Datatype = 'int16';
    case nc_int
        Dataset.Datatype = 'int32';
    case nc_float
        Dataset.Datatype = 'single';
    case nc_double
        Dataset.Datatype = 'double';
end

%
% Assume the current variable does not have an unlimited dimension until
% we know that it does.
Dataset.Unlimited = false;

if ndims == 0
	Dataset.Dimension = {};
	Dataset.Size = 1;
else

	for j = 1:ndims
	
		[dimname, dimlength] = netcdf.inqDim(ncid, dims(j));
	
		Dataset.Dimension{j} = dimname; 
		Dataset.Size(j) = dimlength;
	
		if dims(j) == record_dimension
			Dataset.Unlimited = true;
		end
	end
end

%
% get all the attributes
if natts == 0
	Dataset.Attribute = struct([]);
else
	for attnum = 0:natts-1
		Dataset.Attribute(attnum+1) = nc_get_attribute_struct_tmw(ncid,varid,attnum);
	end
end


if ~getpref('SNCTOOLS','PRESERVE_FVD',false)
	Dataset.Dimension = fliplr(Dataset.Dimension);
	Dataset.Size = fliplr(Dataset.Size);
end





return










