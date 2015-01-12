function nc_attput_tmw ( ncfile, varname, attribute_name, attval )
%NC_ATTPUT_TMW private function for writing attribute with TMW backend.

ncid  =netcdf.open(ncfile, nc_write_mode );

try
    netcdf.reDef(ncid);

    if isnumeric(varname)
        varid = varname;
    else
        varid = netcdf.inqVarID(ncid, varname );
    end
    
    try
        netcdf.putAtt(ncid,varid,attribute_name,attval);
    catch me
        switch(me.identifier)
            case 'MATLAB:netcdf_common:emptySetArgument'
                % Bug #609383
                % Please consult the README.
                %
                % If char, change attval to ' '
                warning('SNCTOOLS:NCATTPUT:emptyAttributeBug', ...
                    'Changing attribute from empty to single space, please consult the README.');
                netcdf.putAtt(ncid,varid,attribute_name,' ');
            otherwise
                rethrow(me);
        end
                
    end
    
    netcdf.endDef(ncid);

catch myException
    netcdf.close(ncid);
    rethrow(myException);
end

netcdf.close(ncid);

return;
