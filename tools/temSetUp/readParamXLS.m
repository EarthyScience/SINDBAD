function x = readParamXLS(x)
if ischar(x)
    if strcmpi(x,'inf'),x=Inf;return;end
    if strcmpi(x,'+inf'),x=+Inf;return;end
    if strcmpi(x,'-inf'),x=-Inf;return;end
    if strcmpi(x,'nan'),x=NaN;return;end
end
    