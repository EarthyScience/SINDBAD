function [start, count] = nc_varput_validate_indexing(ncid,nvdims,data,start,count,stride,isMexnc)
% Check that any given start, count, and stride arguments actually make sense
% for this variable.  
%
% isMexnc is a boolean that tells us if we came in from the mexnc side of 
% thing.  mexnc can't be trusted to handle try/catch, so we'll close the
% file ID here.


% Singletons are a special case.  We need to set the start and count 
% carefully.
if nvdims == 0

    if (isempty(start) && isempty(count) && isempty(stride))

        %
        % This is the case of "nc_varput ( file, var, single_datum );"
        start = 0;
        count = 1;
        
    elseif ((start ==0) && (count == 1))
        
        return

    else
        
        if isMexnc
            mexnc ( 'close', ncid );
        end
        err_id = 'SNCTOOLS:NC_VARPUT:badIndexing';
        err_msg = 'Indexing make no sense for a singleton variable.';
        error ( err_id, err_msg );
    end

    return;

end

% If START and COUNT not given, and if not a singleton variable, then START 
% is [0,..] and COUNT is the size of the data.  
if isempty(start) && isempty(count) && ( nvdims > 0 )
    start = zeros(1,nvdims);
    count = zeros(1,nvdims);
    for j = 1:nvdims
        count(j) = size(data,j);
    end
end


%
% Check that the start, count, and stride arguments have the same length.
if ( numel(start) ~= numel(count) )
    if isMexnc
        mexnc ( 'close', ncid );
    end
    err_id = 'SNCTOOLS:NC_VARPUT_VALIDATE_INDEXING:badStartCount';
    err_msg = 'START and COUNT arguments must have the same length.';
    error ( err_id, err_msg );
end
if ( ~isempty(stride) && (length(start) ~= length(stride)) )
    if isMexnc
        mexnc ( 'close', ncid );
    end
    err_id = 'SNCTOOLS:NC_VARPUT_VALIDATE_INDEXING:badStartStride';
    err_msg = 'START, COUNT, and STRIDE arguments must have the same length.';
    error ( err_id, err_msg );
end






