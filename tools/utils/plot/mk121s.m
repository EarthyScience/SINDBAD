function varargout=mk121s(x,y,xl,yl,varargin)
g=plot(x(:),y(:),'r+',varargin{:});
if exist('xl','var'),xlabel(xl),end
if exist('yl','var'),ylabel(yl),end
set_gcf(gcf,gca,'square',1)
if nargout>=1,varargout{1}=g;end
