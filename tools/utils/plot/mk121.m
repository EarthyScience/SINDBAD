function mk121(x,y,xl,yl,varargin)
figure
plot(x(:),y(:),'r+',varargin{:})
if exist('xl','var'),xlabel(xl),end
if exist('yl','var'),ylabel(yl),end
set_gcf(gcf,gca,'square',1)