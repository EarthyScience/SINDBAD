function nc_dump(file_name, varargin)
%nc_dump  Print netCDF metadata.
%   NC_DUMP(NCFILE) prints metadata about the netCDF file NCFILE.  NC_DUMP
%   is a counterpart to the 'ncdump' utility that comes with the netCDF
%   library.
%
%   NC_DUMP(NCFILE,VARNAME) prints metadata about just the one netCDF 
%   variable named VARNAME.
%
%   NC_DUMP(NCFILE,<VARNAME>,fid) prints output to file opened 
%   with fid = fopen(...) instead of to screen (default fid=1: screen).
%   NC_DUMP(NCFILE,VARNAME,<'fname'>) prints output to new file 'fname'.
%
%   If the preference 'USE_JAVA' is set to true and netcdf-java is on the
%   javaclasspath, NC_DUMP can also display metadata for GRIB2 files and 
%   OPeNDAP URLS files as if they were netCDF files.
%
%   Setting the preference 'PRESERVE_FVD' to true will compel MATLAB to 
%   display the dimensions in the opposite order from what the C utility 
%   ncdump displays.  
% 
%   Example:  This example file is shipped with R2008b.
%       nc_dump('example.nc');
%  
%   Example:  Display metadata for an OPeNDAP URL.  This requires the
%   netcdf-java backend.
%       url = 'http://coast-enviro.er.usgs.gov/models/share/balop.nc';
%       nc_dump(url);
%
%   See also nc_info.

if nargin == 2
if ischar(varargin{1})
    do_restricted_variable = true;
    restricted_variable    = varargin{1};
    if nargin==3
        fid                    = varargin{2};
    else
        fid                    = 1;
    end
elseif isnumeric(varargin{1})
    do_restricted_variable = false;    
    restricted_variable    = [];
    fid                    = varargin{1};
end
else
    do_restricted_variable = false;    
    restricted_variable    = [];
    fid                    = 1;
end

if ischar(fid)
    close_fid = 1;    
    fid = fopen(fid,'w');
else
    close_fid = 0;    
end

metadata = nc_info ( file_name );


fprintf (fid, '%s %s { \n\n', metadata.Format, metadata.Filename );
dump_dimension_metadata( metadata, fid );
dump_variable_metadata ( metadata, restricted_variable, fid);
if ( do_restricted_variable == false )
    dump_global_attributes ( metadata , fid );
end

if close_fid
    fclose(fid);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_dimension_metadata ( metadata, fid )

if isfield ( metadata, 'Dimension' )
    num_dims = length(metadata.Dimension);
else
    num_dims = 0;
end

fprintf (fid, 'dimensions:\n' );
for j = 1:num_dims
    if metadata.Dimension(j).Unlimited
        fprintf(fid, '\t%s = UNLIMITED ; (%i currently)\n', ...
                 deblank(metadata.Dimension(j).Name), metadata.Dimension(j).Length );
    else
        fprintf(fid, '\t%s = %i ;\n', metadata.Dimension(j).Name, metadata.Dimension(j).Length );
    end
end
fprintf(fid,'\n\n');

return







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_variable_metadata ( metadata, restricted_variable , fid)

if isfield ( metadata, 'Dataset' )
    num_vars = length(metadata.Dataset);
else
    num_vars = 0;
end

fprintf (fid,'variables:\n' );
pfvd = getpref('SNCTOOLS','PRESERVE_FVD',false);
if pfvd == 0;
   fprintf (fid,'\t// Preference ''PRESERVE_FVD'':  false,\n' );
   fprintf (fid,'\t// dimensions consistent with ncBrowse, not with native MATLAB netcdf package.\n' );
else
   fprintf (fid,'\t// Preference ''PRESERVE_FVD'':  true,\n' );
   fprintf (fid,'\t// dimensions consistent with native MATLAB netcdf package, not with ncBrowse.\n' );
end

for j = 1:num_vars

    if ~isempty(restricted_variable)
        if ~strcmp ( restricted_variable, metadata.Dataset(j).Name )
            continue
        end
    end

    dump_single_variable ( metadata.Dataset(j) , fid );

end
fprintf (fid,'\n\n' );
return





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_single_variable ( var_metadata , fid )

fprintf(fid,'\t%s ', var_metadata.Datatype);

fprintf(fid,'%s', var_metadata.Name );

if isempty(var_metadata.Dimension) 
    fprintf (fid, '([]), ' );
else
    fprintf (fid, '(%s', var_metadata.Dimension{1} );
    for k = 2:length(var_metadata.Size)
        fprintf (fid, ',%s', var_metadata.Dimension{k} );
    end
    fprintf (fid, '), ');
end


if isempty(var_metadata.Dimension)
    fprintf (fid, 'shape = [1]' );
else
    fprintf (fid, 'shape = [%d', var_metadata.Size(1)  );
    for k = 2:length(var_metadata.Size)
        fprintf (fid, ' %d', var_metadata.Size(k)  );
    end
    fprintf (fid, ']');
end

fprintf (fid,'\n');

%
% Now do all attributes for each variable.
num_atts = length(var_metadata.Attribute);
for k = 1:num_atts
    dump_single_attribute ( var_metadata.Attribute(k), var_metadata.Name , fid );
end

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_single_attribute ( attribute, varname , fid )

if isnumeric(varname)
   fid = varname;
   clear varname
end

switch ( attribute.Datatype )
    case ''
        att_val = '';
        att_type = 'NC_NAT';
    case 'int8'
        att_val = sprintf ('%d ', fix(attribute.Value) );
        att_type = 'b';
    case 'uint8'
        att_val = sprintf ('%d ', fix(attribute.Value) );
        att_type = 'ub';        
    case 'char'
        att_val = sprintf ('"%s" ', attribute.Value );
        att_type = '';
    case 'int16'
        att_val = sprintf ('%i ', attribute.Value );
        att_type = 's';
     case 'uint16'
        att_val = sprintf ('%d ', attribute.Value );
        att_type = 'us';       
    case 'int32'
        att_val = sprintf ('%i ', attribute.Value );
        att_type = 'd';
    case 'uint32'
        att_val = sprintf ('%i ', attribute.Value );
        att_type = 'ud';       
    case 'single'
        att_val = sprintf ('%f ', attribute.Value );
        att_type = 'f';
    case 'double'
        att_val = sprintf ('%g ', attribute.Value );
        att_type = '';
    otherwise
        error('unhandled datatype "%s"', attribute.Datatype);
end

if ~exist('varname','var')
    fprintf(fid, '\t\t:%s = %s%s\n', ...
         attribute.Name, att_val, att_type);
else
    fprintf(fid, '\t\t%s:%s = %s%s\n', ...
         varname, attribute.Name, att_val, att_type);
end

return
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_global_attributes ( metadata , fid )


if isfield ( metadata, 'Attribute' )
    num_atts = length(metadata.Attribute);
else
    num_atts = 0;
end

if num_atts > 0
    fprintf (fid, '//global attributes:\n' );
end

for k = 1:num_atts
   dump_single_attribute ( metadata.Attribute(k) , fid );
end


fprintf (fid, '}\n' );

return
