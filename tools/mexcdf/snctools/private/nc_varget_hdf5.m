function vardata = nc_varget_hdf5(ncfile,varname,start,count,stride)
% 
% This function requires HDFTOOLS in order to work.

preserve_fvd = getpref('SNCTOOLS','PRESERVE_FVD',false);

% HDFTOOLS expects PRESERVE_FVD scenario.
if ~preserve_fvd
    start = fliplr(start);
    count = fliplr(count);
    stride = fliplr(stride);
end
    

% If COUNT has negative values, then we have to figure out how big the
% dataset is before passing off to H5VARGET.
if (nargin >=4) && any(count<0)
	try	
		file_id    = H5F.open(ncfile, 'H5F_ACC_RDONLY', 'H5P_DEFAULT' );
		dataset_id = H5D.open(file_id,varname);
		space_id = H5D.get_space(dataset_id);
        
		[n,dims] = H5S.get_simple_extent_dims(space_id); %#ok<ASGLU>
        dims = fliplr(dims);
        
		idx = find(count<0);
		count(idx) = dims(idx) - start(idx);

	catch me
		if exist(space_id,'var')
			H5S.close(space_id);
		end
		if exist(dataset_id,'var')
			H5D.close(dataset_id,'var');
		end
		if exist(file_id,'var')
			H5F.close(file_id);
        end
        rethrow(me);
    end
	H5S.close(space_id);
	H5D.close(dataset_id);
	H5F.close(file_id);
end

vardata = h5varget(ncfile,varname,start,count,stride);

if (ndims(vardata) < 3) && ((size(vardata,1) == 1) || size(vardata,2) == 1)
	% force to be a column
	if size(vardata,1) == 1
    	vardata = reshape(vardata,size(vardata,2),1);
	end
else
    if ~preserve_fvd
        pv = fliplr ( 1:ndims(vardata) );
        vardata = permute(vardata,pv);
    end
end 

vardata = handle_fill_value(ncfile,varname,vardata);
vardata = handle_missing_value(ncfile,varname,vardata);
vardata = handle_scaling(ncfile,varname,vardata);


%--------------------------------------------------------------------------
function vardata = handle_scaling(ncfile,varname,vardata)

has_scaling = false;

try
    scale_factor = h5attget(ncfile,varname,'scale_factor');
    scale_factor = double(scale_factor);
    has_scaling = true;
catch me
    if strcmp(me.identifier,'MATLAB:hdf5lib2:H5Aopen_name:failure')
        scale_factor = 1.0;
    else
        rethrow(me);
    end
end

try
    add_offset = h5attget(ncfile,varname,'add_offset');
    add_offset = double(add_offset);
    has_scaling = true;
catch me
    if strcmp(me.identifier,'MATLAB:hdf5lib2:H5Aopen_name:failure')
        add_offset = 0.0;
    else
        rethrow(me);
    end
end
    
if has_scaling
    vardata = scale_factor * double(vardata) + add_offset;
end

return



%--------------------------------------------------------------------------
function vardata = handle_fill_value ( ncfile, varname, vardata )

has_fill_value = false;

try
    fv = h5attget(ncfile,varname,'_FillValue');
    fv = double(fv);
    has_fill_value = true;
catch me
    if strcmp(me.identifier,'MATLAB:hdf5lib2:H5Aopen_name:failure')
        % No fill value
		return
    else
        rethrow(me);
    end
end


vardata = double(vardata);
vardata(vardata==fv) = NaN;

return






%--------------------------------------------------------------------------
function vardata = handle_missing_value ( ncfile, varname, vardata )
% HANDLE_MISSING_VALUE
%     If there is a missing value, then replace such values with NaN.

has_missing_value = false;

% If there is a fill value attribute, then that had precedence.  Do nothing.
try
    fv = h5attget(ncfile,varname,'_FillValue');
	return;
catch me
	;
end

try
    mv = h5attget(ncfile,varname,'missing_value');
catch me
	return
end

vardata = double(vardata);
vardata(vardata==mv) = NaN;

return






