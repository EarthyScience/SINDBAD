function set_gcf(cf, ca, style, samevar, figdims, scalefontsize,forcelims,ticklengths)
% function to make a current figure "nicer"
if ~exist('style', 'var')   , style     = 'rectangle';  end
if ~exist('samevar', 'var') , samevar    = 0;  end
if ~exist('scalefontsize', 'var') , scalefontsize    = 1;  end
if ~exist('forcelims','var'), forcelims = []; end
if ~exist('ticklengths','var'), ticklengths = []; end
if ~exist('figdims','var'), figdims = []; end

% figure dimensions
left    = 0;
bottom    = 0;
switch lower(style)
    case {'r','rect','rectangle'}
        width    = 20;
        height    = 15;
    case {'s','sq','square'}
        width    = 20;
        height    = 20;
    otherwise
        error(['not a known style : ' style])
end
if exist('figdims', 'var')
    if ~isempty(figdims)
        width    = figdims(1);
        height    = figdims(2);
    end
end


if isunix
    set_gcf_UNIX(cf, ca, style, samevar, figdims, scalefontsize,forcelims,ticklengths)
end

set(cf,'PaperUnits','centimeters')
set(cf,'PaperType','A4')

xlim = get(ca, 'XLim');
ylim = get(ca, 'YLim');


set(cf, ...
    'PaperPosition' , [left, bottom, width, height], ...
    'PaperSize'     , [width height], ...
    'PaperUnits'    , 'centimeters' ...
    )

% font styles and sizes
fontnamelabel   = 'Times';
fontsizelabel    = floor(24 * scalefontsize);
fontnameaxis   = 'Times';
fontsizeaxis    = floor(14 * scalefontsize);
set(get(ca, 'XLabel'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel,'FontUnits','points')
set(get(ca, 'YLabel'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel,'FontUnits','points')
set(get(ca, 'ZLabel'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel,'FontUnits','points')
set(get(ca, 'Title'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel,'FontUnits','points')
set(ca, 'FontName', fontnameaxis, 'fontsize', fontsizeaxis)
% get(ca,'TickLength')
if exist('ticklengths','var')
    if ~isempty(ticklengths)
        set(ca,'TickLength',ticklengths)
    end
end

% check if there is a colorbar and format it
ax = findobj(cf,'type','axes');
for i = 1:numel(ax)
    if isa(handle(ax(i)), 'scribe.colorbar')
        set(get(handle(ax(i)), 'XLabel'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel,'FontUnits','points')
        set(get(handle(ax(i)), 'YLabel'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel,'FontUnits','points')
        set(get(handle(ax(i)), 'ZLabel'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel,'FontUnits','points')
        set(get(handle(ax(i)), 'Title'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel,'FontUnits','points')
    end
end

% miscellaneous
set(ca, 'TickDir'   , 'out')
set(ca, 'Box'       , 'on')

if samevar && strcmpi(style, 'square')
    axis(ca , 'equal')
    getLims=1;
    if exist('forcelims','var')
        if ~isempty(forcelims)
            lims    = forcelims;
                xlims    = lims;
                ylims   = lims;
                getLims=0;
        end
    end
    if getLims
        lims    = [get(ca, 'XLim') get(ca, 'YLim')];
        lims    = [min(lims) max(lims)];
        try
            xdata    = cell2mat(get(get(gca,'Children'),'XData'));
            ydata    = cell2mat(get(get(gca,'Children'),'YData'));
            xlims    = [min(xdata(:)) max(xdata(:))];
            ylims    = [min(ydata(:)) max(ydata(:))];
        catch
            xlims    = lims;
            ylims   = lims;
        end
    end
    hold on
    plot(ca, lims, lims, 'k-')
    set(ca, 'XLim', xlims, 'YLim', ylims)
else
    set(ca, 'XLim', xlim, 'YLim', ylim)
end
