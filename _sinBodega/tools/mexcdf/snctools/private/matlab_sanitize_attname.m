function sanitized_attname = matlab_sanitize_attname ( attname )
    %
    % could the attribute name  be interpreted as a number?
    % If so, must fix this.
    % An attribute name of, say, '0' is not permissible in matlab
    if ~isnan(str2double(attname))
        sanitized_attname = ['SNC_' attname];
    elseif ( attname(1) == '_' )
        sanitized_attname = ['SNC_' attname];
    else
        sanitized_attname = attname;

        %
        % Does the attribute have non-letters in the leading 
        % position?  Convert these to underscores.  
        if ( ~isletter(attname(1)) );
            sanitized_attname(1) = '_';
        end
    end
return

