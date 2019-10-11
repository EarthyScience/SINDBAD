function mk121(x,y,xl,yl,varargin)
figure
plot(x(:),y(:),'r+',varargin{:})
axis tight
xlim=get(gca,'XLim');
ylim=get(gca,'YLim');
flim=[min([xlim ylim]) max([xlim ylim])];
if exist('xl','var'),xlabel(xl),end
if exist('yl','var'),ylabel(yl),end
set(gca,'XLim',flim,'YLim',flim)
set_gcf(gcf,gca,'square',1)
