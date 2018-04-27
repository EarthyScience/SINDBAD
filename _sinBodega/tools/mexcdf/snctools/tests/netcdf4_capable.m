function bool = netcdf4_capable()
% Is the current mexnc installation capable of netcdf-4 operations?

try
	v = mexnc('inq_libvers');
catch
	bool = false;
	return
end
if v(1) == '4'
	bool = true;
else
	bool = false;
end
return

