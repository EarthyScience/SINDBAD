function actData = test_readFullFloatVariableNc4_tmw ( ncfile )
try 
    actData = nc_varget ( ncfile, 'latitude' );
catch me
    switch(me.identifier)
        case 'MATLAB:Java:GenericException'
            warning ( 'Could not read an NC4 file, make sure you have >= version 4.0 of toolsUI installed.\n' );
            return

        case 'MATLAB:netcdf:open:notANetcdfFile'
            warning ( 'Netcdf-4 files not currently supported with native matlab package.\n' );
            return

        otherwise
            error(eid,emsg);
    end


end
