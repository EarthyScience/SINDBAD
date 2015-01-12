function [retrieval_method,fmt] = snc_read_backend(ncfile)

tmw_gt_r2008a = false;

use_java = getpref('SNCTOOLS','USE_JAVA',false);
fmt = snc_format(ncfile);

v = version('-release');
switch ( v )
    case { '11', '12' };
		error('Not supported on releases below R13.');

    case { '13', '14', '2006a', '2006b', '2007a' }
        
    case { '2007b', '2008a' }
        if strcmp(computer,'PCWIN64') && use_java && ...
			(strcmp(fmt,'netCDF') || strcmp(fmt,'netCDF-4') ...
			 || strcmp(fmt,'GRIB') || strcmp(fmt,'GRIB2'))
            retrieval_method = 'java';
            return
        end
        if strcmp(computer,'PCWIN64') && strcmp(fmt,'HDF4')
            retrieval_method = 'tmw_hdf4';
            return
        end
		

    case { '2008b', '2009a', '2009b' }
        tmw_gt_r2008a = true;

    otherwise
		% Assume 10a or beyond.
        tmw_gt_r2008a = true;

end


% Check for this early.

if isa(ncfile,'ucar.nc2.NetcdfFile') && use_java
    retrieval_method = 'java';
	fmt = 'netcdf-java';
	return
end



v = mexnc('inq_libvers'); 

    
if tmw_gt_r2008a && strcmp(fmt,'netCDF')
    % Use TMW for all local NC3 files when the version >= R2008b
    retrieval_method = 'tmw';
elseif strcmp(fmt,'netCDF')
    % Local NC3 files should rely on mexnc when the version <= R2008a
    retrieval_method = 'mexnc';
elseif strcmp(fmt,'netCDF-4') && (v(1) == '4')
    % If mexnc says we are at version 4 of the library, use mexnc
    retrieval_method = 'mexnc';
elseif use_java && strcmp(fmt,'GRIB')
    retrieval_method = 'java';
elseif use_java && strcmp(fmt,'GRIB2')
    retrieval_method = 'java';
elseif use_java && strcmp(fmt,'URL')
    retrieval_method = 'java';
elseif use_java && strcmp(fmt,'netCDF-4')
    retrieval_method = 'java';
elseif strcmp(fmt,'URL')
    % a URL when java is not enabled.  Use mexnc
    retrieval_method = 'mexnc';
elseif strcmp(fmt,'netCDF-4') && have_mexnc_mexfile
    % NC4 file where we have <=2008b and java is not an option.
    % Try to use the community mex-file.
    retrieval_method = 'mexnc';  
elseif strcmp(fmt,'HDF4')
    retrieval_method = 'tmw_hdf4';
elseif use_java
    % Last chance is if it is some format that netcdf-java can handle.
    retrieval_method = 'java';
    fmt = 'netcdf-java';
else
    error('SNCTOOLS:unknownBackendSituation', ...
      'Could not determine which backend to use with %s.', ...
       ncfile );
end

return



