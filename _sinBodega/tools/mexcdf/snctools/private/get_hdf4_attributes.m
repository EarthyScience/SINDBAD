function Attribute = get_hdf4_attributes(id,nattrs)
if nattrs == 0
    Attribute = [];
    return;
end

Attribute = repmat(struct('Name','','Datatype','','Value',0),nattrs,1);
for j = 0:nattrs-1
    [name,atype,acount,status] = hdfsd('attrinfo',id,j);
    if status < 0
        error('SNCTOOLS:nc_info:hdf4:attrinfoFailed', ...
            'Could not read attribute %d.\n', j );
    end
    Attribute(j+1).Name = name;
    
    [Attribute(j+1).Value, status] = hdfsd('readattr',id,j);
    if status < 0
        error('SNCTOOLS:nc_info:hdf4:readattrFailed', ...
            'Could not read attribute %d.\n',j );
    end
    Attribute(j+1).Datatype = class(Attribute(j+1).Value);
end
