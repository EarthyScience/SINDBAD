function vinfo = nc_getvarinfo_hdf4(arg1,arg2)
% HDF4 backend for nc_getvarinfo.
if ischar(arg1) && ischar(arg2)
    fid = fopen(arg1,'r');
    filename = fopen(fid);
    fclose(fid);
    sd_id = hdfsd('start',filename,'read');
    if sd_id < 0
        error('SNCTOOLS:nc_info:hdf4:startFailed', ...
            'Unable to gain access to %s.\n', filename);
    end
    idx = hdfsd('nametoindex',sd_id,arg2);
    if idx < 0
        hdfsd('end',sd_id);
        error('SNCTOOLS:nc_info:hdf4:nametoindexFailed', ...
            'Unable to index %s.\n', arg2);
    end
    sds_id = hdfsd('select',sd_id,idx);
    if  sds_id < 0
        hdfsd('end',sd_id);
        error('SNCTOOLS:nc_info:hdf4:selectFailed', ...
            'Unable to select %s.\n', arg2);
    end
    vinfo = get_varinfo_hdf4_numeric(sd_id,sds_id);
    status = hdfsd('endaccess',sds_id);
    if status < 0
        hdfsd('end',sd_id);
        error('SNCTOOLS:nc_info:hdf4:endaccessFailed', ...
            'Unable to end access to %s.\n', arg2);
    end
    status = hdfsd('end',sd_id);
    if status < 0
        error('SNCTOOLS:nc_info:hdf4:endaccessFailed', ...
            'Unable to end access to %s.\n', filename);
    end
    
else
    vinfo = get_varinfo_hdf4_numeric(arg1,arg2);
end


%--------------------------------------------------------------------------
function vinfo = get_varinfo_hdf4_numeric(sd_id,sds_id)
[name,rank,dim_sizes,data_type,nattrs,status] = hdfsd('getinfo',sds_id);
if status < 0
    error('SNCTOOLS:nc_info:hdf4Numeric:getinfoFailed', ...
        'Unable to get information about scientific dataset.\n');
end

vinfo.Name = name;
vinfo.Datatype = data_type;

if hdfsd('isrecord',sds_id)
    vinfo.Unlimited = true;
else
    vinfo.Unlimited = false;
end

if (rank == 0)
    vinfo.Dimension = {};
    vinfo.Size = 1;
else
    for j = 0:rank-1
        dim_id = hdfsd('getdimid',sds_id,j);
        if dim_id < 0
            error('SNCTOOLS:nc_info:hdf4Numeric:getdimidFailed', ...
                'Unable to get a dimension scale identifier for dimension %d for %s.\n',j, vinfo.Name);
        end
        [dname,dcount,ddatatype,dnattrs,status] = hdfsd('diminfo',dim_id);
        if status < 0
            error('SNCTOOLS:nc_info:hdf4Numeric:diminfoFailed', ...
                'Unable to get information about dimension scale %d for %s.\n',j, vinfo.Name);
        end
        vinfo.Dimension{j+1} = dname;
        
        % inf means unlimited, but currently zero.
        if isinf(dcount)
            if isinf(dim_sizes(j+1))
                vinfo.Size(j+1) = 0;
            else
                vinfo.Size(j+1) = dim_sizes(j+1);
            end
        else
            vinfo.Size(j+1) = dcount;
        end
    end
end

if getpref('SNCTOOLS','PRESERVE_FVD')
    vinfo.Dimension = fliplr(vinfo.Dimension);
    vinfo.Size = fliplr(vinfo.Size);
end


vinfo.Attribute = get_hdf4_attributes(sds_id,nattrs);



