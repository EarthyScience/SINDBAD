function nc_add_dimension_tmw ( ncfile, dimension_name, dimension_length )

ncid = netcdf.open(ncfile, nc_write_mode );

try
    netcdf.reDef(ncid );
    netcdf.defDim(ncid, dimension_name, dimension_length);
    netcdf.endDef(ncid );
catch myException
    netcdf.close(ncid);
    rethrow(myException);
end

netcdf.close(ncid);

return







