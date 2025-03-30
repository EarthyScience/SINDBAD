function x = setFlag2Nan(x,flag)
        x(x==flag)=NaN;
end