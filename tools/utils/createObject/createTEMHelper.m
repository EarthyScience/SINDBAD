function [info] = createTEMHelper(info)
% Usages: 
%   info = createTEMHelpers(info)
%
% Requires: 
%   + info and dimension of the spatial and temporal domains (from forcing)
%   + precision to use for arrays
%
% Purposes: 
%   Creates the fields of info.tem.helpers. for empty arrays that can be 
%   accessed by any function.
%
% Conventions: 
%   + (nTix)tix: (size) dimension in time
%   + (nPix)pix: (size) dimension in space
%   + (nZix)zix: (size) dimension for layers in vertical direction
%   + Always use these helpers in the spatialization of scalar values of
%     parameters in the approaches.
%
% Created by: 
%   Sujan Koirala (skoirala)
% 
% References: 
%   + 
%
% Versions: 
%   + 1.0 on 17.04.2018

%%
%% create the helpers for variables that have a either one dimension (pix,1 in space, 1,tix in time) or two (pix,tix in space time)

nPix                                        =   info.tem.helpers.sizes.nPix;
nTix                                        =    info.tem.helpers.sizes.nTix;

info.tem.helpers.arrays.zerospixtix         =   zeros(nPix,nTix,info.tem.model.rules.arrayPrecision);
info.tem.helpers.arrays.zerospix            =   zeros(nPix,1,info.tem.model.rules.arrayPrecision);
info.tem.helpers.arrays.zerostix            =   zeros(1,nTix,info.tem.model.rules.arrayPrecision);
info.tem.helpers.arrays.onespixtix          =   ones(nPix,nTix,info.tem.model.rules.arrayPrecision);
info.tem.helpers.arrays.onespix             =   ones(nPix,1,info.tem.model.rules.arrayPrecision);
info.tem.helpers.arrays.onestix             =   ones(1,nTix,info.tem.model.rules.arrayPrecision);
info.tem.helpers.arrays.nanpixtix           =   nan(nPix,nTix,info.tem.model.rules.arrayPrecision);
info.tem.helpers.arrays.nanpix              =   nan(nPix,1,info.tem.model.rules.arrayPrecision);
info.tem.helpers.arrays.nantix              =   nan(1,nTix,info.tem.model.rules.arrayPrecision);

%% create the helpers for state variables that have a dimension (zix) for number of layers
stateVars                                   =   fields(info.tem.model.variables.states);
for ii  =    1:numel(stateVars)
    sv                                      =   stateVars{ii};
    poolNames                               =   info.tem.model.variables.states.(sv).names;
    for sp=1:numel(poolNames)
            nZix                            =   info.tem.model.variables.states.(sv).nZix.(poolNames{sp});
            eValStrOnesPixZix               =   strcat('info.tem.helpers.arrays.onespixzix.',sv,'.',poolNames{sp}, ' = repmat(info.tem.helpers.arrays.onespix,1,nZix);');
            eValStrZerosPixZix              =   strcat('info.tem.helpers.arrays.zerospixzix.',sv,'.',poolNames{sp}, ' = repmat(info.tem.helpers.arrays.zerospix,1,nZix);');
            eValStrNanPixZix                =   strcat('info.tem.helpers.arrays.nanpixzix.',sv,'.',poolNames{sp}, ' = repmat(info.tem.helpers.arrays.nanpix,1,nZix);');
            eval(eValStrOnesPixZix);
            eval(eValStrZerosPixZix);
            eval(eValStrNanPixZix);
    end
end
end
