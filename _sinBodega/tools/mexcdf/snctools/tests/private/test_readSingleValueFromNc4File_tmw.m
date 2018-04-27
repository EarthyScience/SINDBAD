function actData = test_readSingleValueFromNc4File_tmw(ncfile)
actData = [];
try 
    actData = nc_varget ( ncfile, 'latitude', 1, 1 );
catch me
    switch(me.identifier)
        case 'MATLAB:Java:GenericException'
            fprintf ( 1, 'Could not read a NC4 file, make sure you have >= version 4.0 of toolsUI installed.\n' );
            return
        case 'MATLAB:netcdf:open:notANetcdfFile'
			fprintf ( 1, 'NetCDF-4 files are not yet read via the netcdf package.\n');
            return

        case 'SNCTOOLS:NC_VARGET:MEXNC:OPEN'
            fprintf ( 1, 'Could not read a NC4 file with mexnc.  If this is\n' );
            fprintf ( 1, 'important to you, make sure you have a \n');
            fprintf ( 1, 'netcdf-4-enabled mex-file.\n' );
            return

        otherwise
            error(me.identifier,me.message);
    end


end
