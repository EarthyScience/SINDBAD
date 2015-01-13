function bool = snctools_use_tmw(ncfile)
% Use TMW or mexnc?

%fid = fopen(ncfile,'r');
%x = fread(fid,4,'uint8=>char')
%fclose(fid);

try
	v = mexnc('inq_libvers');
catch 
	% OK, assume we don't have mexnc mex-file
	bool = true;
	return
end

switch ( version('-release') )
    case { '11', '12', '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
		bool = false;
	otherwise
		v = mexnc('inq_libvers');
		if (v(1) == '4')
			bool = false;
		else
			bool = true;
		end
end

