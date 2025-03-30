function varout = adjustVariableBounds(var,varrange,miss_val,varname,repvec)
%checks variable arrays for plausible values and replaces implausible ones by missing values
% INPUT
% var input array
% min minimum value
% max maximum value
% miss_val missing value
% OUTPUT
% varout

% Note: skoirala: 05-02-2021: This function most likely does not work if
% all the data values are outside the range given in input data bounds.May
% need further refinement... For example, if LAI is supposed to between 1
% and 10, and the range/bound is given between 0 and 1, this will fail. 
%%
if~exist('repvec','var');repvec=ones(size(var)).*miss_val;end

v1=min(var(var~=miss_val&isnan(var)==0&isinf(var)==0));
v2=max(var(var~=miss_val&isnan(var)==0&isinf(var)==0));

sstr    =   [pad('MSG BOUNDS INPUT',20) ' : ' pad('adjustVariableBounds',20) ' | ' 'for ' varname ': min: '  num2str(v1) ' max: ' num2str(v2)];
disp(sstr)


varout=var;
pos = find(var<varrange(1));
if(~isempty(pos))
    sstr    =   [pad('MSG ADJ BOUNDS INPUT',20) ' : ' pad('adjustVariableBounds',20) ' | ' 'for ' varname ': replacing '  num2str(length(pos)) ' invalid minima'];
    disp(sstr)
    for i = 1:length(pos)
        varout(pos(i))=repvec(pos(i));
    end
end
pos = find(var>varrange(2));
if(~isempty(pos))
    sstr    =   [pad('MSG ADJ BOUNDS INPUT',20) ' : ' pad('adjustVariableBounds',20) ' | ' 'for ' varname ': replacing '  num2str(length(pos)) ' invalid maxima'];
    disp(sstr)
    for i = 1:length(pos)
        varout(pos(i))=repvec(pos(i));
    end
end
pos = find(isnan(var)==1);
if(~isempty(pos))
    sstr    =   [pad('MSG ADJ BOUNDS INPUT',20) ' : ' pad('adjustVariableBounds',20) ' | ' 'for ' varname ': replacing '  num2str(length(pos)) ' NaN ' ];
    disp(sstr)
    disp(['MSG : check_bounds : for ' varname ': replacing '  num2str(length(pos)) ' NaN ' ]);
    for i = 1:length(pos)
        varout(pos(i))=repvec(pos(i));
    end
end
pos = find(isinf(var)==1);
if(~isempty(pos))
    sstr    =   [pad('MSG ADJ BOUNDS INPUT',20) ' : ' pad('adjustVariableBounds',20) ' | ' 'for ' varname ': replacing '  num2str(length(pos)) ' Inf ' ];
    disp(sstr)
    for i = 1:length(pos)
        varout(pos(i))=repvec(pos(i));
    end
end

