function set_gca_UNIX(ca, style, samevar, scalefontsize, forcelims, ticklengths)
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

xlim = get(ca, 'XLim');
ylim = get(ca, 'YLim');

% font styles and sizes
fontnametitle = 'Times-Roman';
fontsizetitle = floor(20 * scalefontsize);
fontnamelabel = 'Times-Roman';
fontsizelabel = floor(16 * scalefontsize);
fontnameaxis  = 'Times-Roman';
fontsizeaxis  = floor(14 * scalefontsize);
set(get(ca, 'XLabel'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel);
set(get(ca, 'YLabel'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel);
set(get(ca, 'ZLabel'), 'FontName', fontnamelabel, 'FontSize', fontsizelabel);
set(get(ca, 'Title'),  'FontName', fontnametitle, 'FontSize', fontsizetitle);
set(ca,                'FontName', fontnameaxis,  'FontSize', fontsizeaxis);

if exist('ticklengths', 'var')
    if numel(ticklengths) == 2
        set(ca, 'TickLength', ticklengths);
    end
end

% miscellaneous
set(ca, 'TickDir', 'out');
set(ca, 'Box', 'on');

if samevar && strcmpi(style, 'square')
    axis(ca , 'equal');
    calcLims=1;
    if exist('forcelims','var')
        if ~isempty(forcelims)
            lims  = forcelims;
            xlims = lims;
            ylims = lims;
            calcLims=0;
        end
    end
    if calcLims
        lims = [get(ca, 'XLim') get(ca, 'YLim')];
        lims = [min(lims) max(lims)];
        try
            xdata = cell2mat(get(get(gca,'Children'),'XData'));
            ydata = cell2mat(get(get(gca,'Children'),'YData'));
            xlims = [min(xdata(:)) max(xdata(:))];
            ylims = [min(ydata(:)) max(ydata(:))];
        catch
            xlims = lims;
            ylims = lims;
        end
    end
    hold on;
    plot(ca, lims, lims, 'k-');
    set(ca, 'XLim', xlims, 'YLim', ylims);
else
    set(ca, 'XLim', xlim, 'YLim', ylim);
end
