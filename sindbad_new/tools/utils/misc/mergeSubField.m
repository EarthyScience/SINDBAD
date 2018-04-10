function ms = mergeSubField(s1,s2,fn,priorityFlag)

if isfield(s1,fn)&&isfield(s2,fn)
    ms = catstruct(priorityFlag,s1.(fn),s2.(fn));
elseif isfield(s1,fn)&&~isfield(s2,fn)
    ms = s1.(fn);
elseif isfield(s2,fn)&&~isfield(s1,fn)
    ms = s2.(fn);
else
    error(['ERR : mergeSubField : structure fieldname does not exist in either input structure : ' fn])
end
end
