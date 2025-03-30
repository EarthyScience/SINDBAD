function varout = adjustBounds(var,varrange,miss_val,varname,repvec)
%checks variable arrays for plausible values and replaces implausible ones by missing values
% INPUT
% var input array
% min minimum value
% max maximum value
% miss_val missing value
% OUTPUT
% varout

if~exist('repvec','var');repvec=ones(size(var)).*miss_val;end

v1=min(var(var~=miss_val&isnan(var)==0&isinf(var)==0));
v2=max(var(var~=miss_val&isnan(var)==0&isinf(var)==0));
disp(['MSG : check_bounds : for ' varname ': min: '  num2str(v1) ' max: ' num2str(v2) ]);

varout=var;
pos = find(var<varrange(1));
if(~isempty(pos))
    disp(['MSG : check_bounds : for ' varname ': replacing '  num2str(length(pos)) ' invalid minima ' ]);
    for i = 1:length(pos)
        varout(pos(i))=repvec(pos(i));
    end
end
pos = find(var>varrange(2));
if(~isempty(pos))
    disp(['MSG : check_bounds : for ' varname ': replacing '  num2str(length(pos)) ' invalid maxima ' ]);
    for i = 1:length(pos)
        varout(pos(i))=repvec(pos(i));
    end
end
pos = find(isnan(var)==1);
if(~isempty(pos))
    disp(['MSG : check_bounds : for ' varname ': replacing '  num2str(length(pos)) ' NaN ' ]);
    for i = 1:length(pos)
        varout(pos(i))=repvec(pos(i));
    end
end
pos = find(isinf(var)==1);
if(~isempty(pos))
    disp(['MSG : check_bounds : for ' varname ': replacing '  num2str(length(pos)) ' Inf ' ]);
    for i = 1:length(pos)
        varout(pos(i))=repvec(pos(i));
    end
end

