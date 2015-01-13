function fmt = snc_format(theFile)
%SNC_FORMAT  Determine the file format if possible.

% Must check for a URL first, because it doesn't exist as a local file.

if ~isempty(regexp(theFile,'https*://', 'once'))
	fmt = 'URL';
	return;
end


% For the GRIBs and netcdf formats, we need to read a certain number
% of bytes.
afid = fopen(theFile,'r');
if afid == -1
    error('SNCTOOLS:fopen:cannotOpenFile', ...
        'Cannot open %s.  Make sure it is on your path.', ...
        theFile);
end
[signature,count] = fread(afid,8,'uint8=>uint8');
fclose(afid);

if (strcmp(char(signature(1:4))', 'GRIB')) && (signature(8) == 1)
    % GRIB : bytes 1-4 are 'GRIB', and byte 8 is 1.
	fmt = 'GRIB';
	return
elseif (strcmp(char(signature(1:4))', 'GRIB')) && (signature(8) == 2)
    % GRIB 2 : bytes 1-4 are 'GRIB', and byte 8 is 2.
	fmt = 'GRIB2';
	return
elseif (strcmp(char(signature(1:3))', 'CDF')) && (signature(4) == 1)
    % netcdf classic : bytes 1-3 are 'CDF', and byte 4 is 1.
	fmt = 'netCDF';
	return
elseif (strcmp(char(signature(1:3))', 'CDF')) && (signature(4) == 2)
    % netcdf 64bit offset : bytes 1-3 are 'CDF', and byte 4 is 2.
	fmt = 'netCDF';
	return
elseif (strcmp(char(signature(2:4))', 'HDF'))
    % netcdf-4 : bytes 2-4 are 'HDF'.  We just assume that it's netcdf-4.
	% We really can't determine the difference betweeen netcdf-4 and 
	% regular HDF5 this way.
	fmt = 'netCDF-4';
	return
end

% Could it be HDF4?  Do this check last, because non-windows versions
% of matlab would identify a netcdf file as HDF thru 2009b.

fid = fopen(theFile,'r');
filename = fopen(fid);
fclose(fid);

fid = hdfh('open',filename,'read',0);
if fid >= 0
	fmt = 'HDF4';
	hdfh('close',fid);
	return
end

% We couldn't figure out what it was.
fmt = 'unknown';


return


