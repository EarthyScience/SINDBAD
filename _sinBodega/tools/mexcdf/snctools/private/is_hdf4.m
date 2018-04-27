function bool = is_hdf4(ncfile)
% tests if a file is HDF4 or not.
fid = fopen(ncfile,'r');
filename = fopen(fid);
fclose(fid);

fid = hdfh('open',filename,'read',0);
if fid < 0
    bool = false;
else
    bool = true;
end