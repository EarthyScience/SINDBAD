function set_gcf_UNIX(cf, ca, style, samevar, figdims, scalefontsize, ...
    forcelims, ticklengths)
% function to make a current figure "nicer"

if ~exist('style', 'var')
    style = 'rectangle';
end
if ~exist('samevar', 'var')
    samevar = 0;
end
if ~exist('scalefontsize', 'var')
    scalefontsize = 1;
end

% figure dimensions
switch lower(style)
    case {'r','rect','rectangle'}
        width  = 20;
        height = 15;
    case {'s','sq','square'}
        width  = 20;
        height = 20;
    otherwise
        error(['not a known style : ' style])
end
if exist('figdims', 'var')
    if ~isempty(figdims)
        width  = figdims(1);
        height = figdims(2);
    end
end

set(cf, 'PaperUnits', 'centimeters');
set(cf, 'PaperSize', [width height]);

if scalefontsize > 0.0
    fontnamelabel = 'Times-Roman';
    fontsizelabel = floor(16 * scalefontsize);

    % check if there is a colorbar and format it
    ax = findobj(cf, 'type', 'axes');
    for i = 1:numel(ax)
        if isa(handle(ax(i)), 'scribe.colorbar')
            set(get(handle(ax(i)), 'XLabel'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel);
            set(get(handle(ax(i)), 'YLabel'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel);
            set(get(handle(ax(i)), 'ZLabel'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel);
            set(get(handle(ax(i)), 'Title'),  'FontName', fontnamelabel, 'FontSize', fontsizelabel);
        end
    end

    if ~exist('forcelims', 'var')
        set_gca_UNIX(ca, style, samevar, scalefontsize);
    else
        if ~exist('ticklengths', 'var')
            set_gca_UNIX(ca, style, samevar, scalefontsize, forcelims);
        else
            set_gca_UNIX(ca, style, samevar, scalefontsize, forcelims, ticklengths);
        end
    end
end
