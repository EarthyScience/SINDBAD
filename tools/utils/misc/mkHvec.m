function x = mkHvec(x,mkV)
% make an horizontal vector, or vertical if(mkV)
if isempty(x)
    return
end

if ndims(x) ~= 2
    error(['input must have 2 dimensions! ndims(x) = ' num2str(ndims(x))])
end

if size(x, 1) == 1
    return
elseif size(x, 2) == 1
    x    = x';
else
    error(['one of input dimensions must be 1! size(x)=' num2str(size(x))])
end

if exist('mkV','var')
    if mkV
        x    = x';
    end
end
