function varargout=mk121s(x,y,xl,yl,varargin)
g=plot(x(:),y(:),'+',varargin{:});
axis tight
xlim=get(gca,'XLim');
ylim=get(gca,'YLim');
flim=[min([xlim ylim]) max([xlim ylim])];
if exist('xl','var'),xlabel(xl),end
if exist('yl','var'),ylabel(yl),end
set_gcf(gcf,gca,'square',1)
set(gca,'XLim',flim,'YLim',flim)
if nargout>=1,varargout{1}=g;end
