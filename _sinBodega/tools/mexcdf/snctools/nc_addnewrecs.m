function new_data = nc_addnewrecs(ncfile,input_buffer,record_variable) %#ok<INUSD>
%NC_ADDNEWRECS:  Append records to netcdf file.
%   new_data = nc_addnewrecs (ncfile,record_struct) appends
%   records in record_struct to the end of a netcdf file.  The data for the
%   record variable itself must be monotonically increasing.   Only those
%   records that are actually newer (in the sense of time series) than the
%   last record in the file are returned in the new_data structure.  Any
%   records that are "older" than the last record are ignored.
%   
%   The difference between this m-file and nc_add_recs is that this 
%   routine assumes that the unlimited dimension has a monotonically
%   increasing coordinate variable, e.g. time series.  This routine
%   actually calls nc_add_recs with suitable arguments.
%  
%   If the length of the record variable data that is to be appended is
%   just one, then a check is made for the rest of the incoming data to
%   make sure that they also have the proper rank.  This addresses the
%   issue of squeezed-out leading singleton dimensions.
%  
%   From this point foreward, assume we are talking about time series.
%   It doesn't have to be that way (the record variable could be 
%   monotonically increasing spatially instead ), but talking about it
%   in terms of time series is just easier.  If a field is present in 
%   the structure, but not in the netcdf file, then that field is 
%   ignored.  
%    
%   The dimensions of the data should match that of the target netcdf file.  
%   For example, suppose an ncdump of the NetCDF file looks something like
%
%       netcdf a_netcdf_file {
%       dimensions:
%           lat = 1 ;
%           lon = 2 ;
%           depth = 2 ; 
%           time = UNLIMITED ; // (500 currently)
%       variables:
%           double time(time) ;
%           float var1(time, depth) ;
%           float var2(time, depth, lat, lon) ;
%           float var3(time, depth, lat) ;
%       
%       // global attributes:
%       }
% 
%   The "input_input_buffer" should look something like the following:
%
%       >> input_input_buffer
%
%       input_input_buffer =
%
%           time: [3x1 double]
%           var1: [3x2 double]
%           var2: [4-D double]
%           var3: [3x2 double]
%
%   The reason for the possible size discrepency here is that matlab will
%   ignore trailing singleton dimensions (but not interior ones, such as
%   that in var2.
%  
%   If a netcdf variable has no corresponding field in the input struct,
%   then the corresponding NetCDF variable will populate with the
%   appropriate _FillValue for each new time step.
%  
%   See also nc_varput, nc_cat.


new_data = [];
error(nargchk(2,3,nargin,'struct'));


if isempty ( input_buffer )
    return
end

record_variable = find_record_variable(ncfile);

% Check that the record variable is present in the input buffer.
if ~isfield ( input_buffer, record_variable )
    error ( 'SNCTOOLS:NC_ADDNEWRECS:missingRecordVariable', ...
            'input structure is missing the record variable ''%s''.\n', record_variable );
end


% Remove any fields that aren't actually in the file.
[input_buffer, vsize] = restrict_to_those_in_file(input_buffer,ncfile);


%
% If the length of the record variable data to be added is just one,
% then we may have a special corner case.  The leading dimension might
% have been squeezed out of the other variables.  MEXNC wants the rank
% of the incoming data to match that of the infile variable.  We address 
% this by forcing the leading dimension in these cases to be 1.
input_buffer = force_rank_match ( ncfile, input_buffer, record_variable );

%
% Retrieve the dimension id of the unlimited dimension upon which
% all depends.  
varinfo = nc_getvarinfo ( ncfile, record_variable );


%
% Get the last time value.   If the record variable is empty, then
% only take datums that are more recent than the latest old datum
input_buffer_time_values = input_buffer.(record_variable);
if varinfo.Size > 0
    last_time = nc_getlast ( ncfile, record_variable, 1 );
    recent_inds = find( input_buffer_time_values > last_time );
else
    recent_inds = 1:length(input_buffer_time_values);
end



%
% if no data is new enough, just return.  There's nothing to do.
if isempty(recent_inds)
    return
end



%
% Go thru each variable.  Restrict to what's new.
varnames = fieldnames ( input_buffer );
for j = 1:numel(varnames)
    data = input_buffer.(varnames{j});

    if getpref('SNCTOOLS','PRESERVE_FVD',false) 
        %&& (ndims(data) > 1) && (size(data,ndims(data)) > 1)
        if numel(vsize.(varnames{j})) == 1
            % netCDF variable is 1D
            restricted_data = data(recent_inds);
        elseif (numel(vsize.(varnames{j})) == 2) 
            % netCDF variable is 2D
            restricted_data = data(:,recent_inds);
        elseif (ndims(data) < numel(vsize.(varnames{j}))) && (numel(recent_inds) == 1)
            % netCDF variable is more than 2D, but we are given just one record.
            restricted_data = data;
        else
            cmdstring = repmat(':,',1,ndims(data)-1);
            cmdstring = sprintf ( 'restricted_data = data(%srecent_inds);', cmdstring );
            eval(cmdstring);
        end
    else
        if numel(vsize.(varnames{j})) == 1
            % netCDF variable is 1D
            restricted_data = data(recent_inds);
        elseif (numel(vsize.(varnames{j})) == 2) 
            % netCDF variable is 2D
            restricted_data = data(recent_inds,:);
        elseif (ndims(data) < numel(vsize.(varnames{j}))) && (numel(recent_inds) == 1)
            % netCDF variable is more than 2D, but we are given just one record.
            restricted_data = data;
        else
            cmdstring = repmat(',:',1,ndims(data)-1);
            cmdstring = sprintf ( 'restricted_data = data(recent_inds%s);', cmdstring );
            eval(cmdstring);
        end
    end


    input_buffer.(varnames{j}) = restricted_data;
end



%
% Write the records out to file.
nc_add_recs(ncfile,input_buffer);


new_data = input_buffer;




return;





%==============================================================================
function input_buffer = force_rank_match ( ncfile, input_buffer, record_variable )
% If the length of the record variable data to be added is just one,
% then we may have a special corner case.  The leading dimension might
% have been squeezed out of the other variables.  MEXNC wants the rank
% of the incoming data to match that of the infile variable.  We address 
% this by forcing the leading dimension in these cases to be 1.

varnames = fieldnames ( input_buffer );
num_vars = length(varnames);
if length(input_buffer.(record_variable)) == 1 
    for j = 1:num_vars

        %
        % Skip the record variable, it's irrelevant at this stage.
        if strcmp ( varnames{j}, record_variable )
            continue;
        end

        infile_vsize = nc_varsize(ncfile, varnames{j} );

        %
        % Disregard any trailing singleton dimensions.
        %effective_nc_rank = calculate_effective_nc_rank(infile_vsize);

        if (numel(infile_vsize) > 2) && (ndims(input_buffer.(varnames{j})) ~= numel(infile_vsize))
            %
            % Ok we have a mismatch.
            if getpref('SNCTOOLS','PRESERVE_FVD',true)
                rsz = [infile_vsize(1:end-1) numel(input_buffer.(record_variable))]; 
            else
                rsz = [numel(input_buffer.(record_variable)) infile_vsize(2:end) ]; 
            end
            input_buffer.(varnames{j}) = reshape( input_buffer.(varnames{j}), rsz );
        end


    end
end



%------------------------------------------------------------------------
function [input_buffer, vsize] = restrict_to_those_in_file(input_buffer,ncfile)

%
% check to see that all fields are actually there.
nc = nc_info ( ncfile );
num_nc_vars = length(nc.Dataset);

vsize = [];

fnames = fieldnames ( input_buffer );
num_fields = length(fnames);
for j = 1:num_fields
    not_present = 1;
    for k = 1:num_nc_vars
        if strcmp(fnames{j}, nc.Dataset(k).Name)
            not_present = 0;

            % Store the dataset size.
            vsize.(fnames{j}) = nc.Dataset(k).Size;
        end
    end
    if not_present
        fprintf ( 1, '  %s not present in file %s.  Ignoring it...\n', fnames{j}, ncfile );
        input_buffer = rmfield ( input_buffer, fnames{j} );
    end
end


