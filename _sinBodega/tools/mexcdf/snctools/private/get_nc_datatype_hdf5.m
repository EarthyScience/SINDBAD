function nctype = get_nc_datatype_hdf5(dtype)
	class_id = H5T.get_class(dtype);

	switch ( class_id )
	    case H5ML.get_constant_value('H5T_INTEGER')
	        if H5T.equal(dtype,'H5T_STD_I8BE')
	            nctype = 1;
	        elseif H5T.equal(dtype,'H5T_STD_I8LE')
	            nctype = 1;
	        elseif H5T.equal(dtype,'H5T_STD_I16BE')
                nctype = 3;
            elseif H5T.equal(dtype,'H5T_STD_I16LE')
                nctype = 3;
            elseif H5T.equal(dtype,'H5T_STD_I32BE')
                nctype = 4;
            elseif H5T.equal(dtype,'H5T_STD_I32LE')
                nctype = 4;
            else
	            error('SNCTOOLS:get_varinfo_hdf5:unrecognizedIntegerType', ...
	                  'Encountered an unrecognized integer type.' );
	        end
	
	    case H5ML.get_constant_value('H5T_FLOAT')
	        if H5T.equal(dtype,'H5T_IEEE_F32BE')
	            nctype = 5;
	        elseif H5T.equal(dtype,'H5T_IEEE_F32LE')
	            nctype = 5;
	        elseif H5T.equal(dtype,'H5T_IEEE_F64BE')
	            nctype = 6;
	        elseif H5T.equal(dtype,'H5T_IEEE_F64LE')
	            nctype = 6;
	        else
	            error('SNCTOOLS:get_varinfo_hdf5:unrecognizedFloatType', ...
	                  'Encountered an unrecognized floating point type.' );
	        end
	
	    case { H5ML.get_constant_value('H5T_OPAQUE') ...
		       H5ML.get_constant_value('H5T_REFERENCE') ...
			   H5ML.get_constant_value('H5T_COMPOUND') ...
			   H5ML.get_constant_value('H5T_ENUM') ...
			   H5ML.get_constant_value('H5T_ARRAY') ...
			   H5ML.get_constant_value('H5T_BITFIELD') ...
			   H5ML.get_constant_value('H5T_VLEN') }
	        error('SNCTOOLS:get_varinfo_hdft:unrecognizedClass', ...
	              'Encountered an unrecognized datatype class %d.', ...
	              class_id);

	    case H5ML.get_constant_value('H5T_STRING')
	        nctype = 2;
	
	    otherwise
	        error('SNCTOOLS:get_varinfo_hdft:unrecognizedClass', ...
	              'Encountered an unrecognized datatype class %d.', ...
	              class_id);
	end

return


