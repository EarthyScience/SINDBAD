function info = editINFOSettings(info, varargin)
%% reads configuration files for TEM, opti or postProcessing and puts them into the info
% INPUT:    info       :    info structure
%           varargin{:}:	list of fields in info structure to change
%                           ('Fieldname' : new value)
% OUTPUT:   structure 'info' with changed values or information on what
%           went wrong

% steps:
%   1) read varargin
%   2) get all fieldnames of info
%   3) search for fieldnames in info, with 3 possible results:
%        - fieldname is not known
%        - fieldname is changed
%        - fieldname is not unique

% If the fieldname to change is not unique, the functions displays all
% possible options and the input fieldname needs to be the full "structure-path"
% for this key (e.g.: info.tem.model.modules.Qsnw.apprName)

%% 1) Check and read varargin
if mod(nargin-1,2) == 0 %number is even else %number is odd end
    keySet = varargin(1 : 2 : end);  
    valueSet = varargin(2 : 2 : end);    
else
    error('Number of arguments in varargin needs to be even as it represents a list of "Fieldname : newValue" pairs.');     
end
    
%% 1) Load, unfold and separate all fieldnames (endnodes) of Info structure
[infoFieldnames, ~] = getAllFieldnames(info,false,{},1);
infoFieldnamesParts{1,size(infoFieldnames, 2)} = []; infoFieldnamesEndnodes{1,size(infoFieldnames, 2)} = []; 
for ii = 1 : size(infoFieldnames, 2)
    infoFieldnamesParts{ii} = strsplit(infoFieldnames{ii}, '.');
    infoFieldnamesEndnodes(ii) = infoFieldnamesParts{ii}(1, end);
end

%% 2) Search for fieldnames which content is intended to change and change value or display information
for ii = 1 : size(keySet,2)    
    if ~contains(cellstr(keySet(ii)),'.')
        findPosInd = strfind(infoFieldnamesEndnodes, keySet{ii});
        findPosInd = find(~cellfun('isempty',findPosInd));
        no_of_occurences = size(findPosInd, 2);
    else
        findPosInd = strfind(infoFieldnames, keySet{ii});
        findPosInd = find(~cellfun('isempty',findPosInd));
        no_of_occurences = size(findPosInd, 2);
    end
    
    switch no_of_occurences
        case 0
            error(['Fieldname "' keySet{ii} '" not found in Structure.']);
        case 1  
            info = setfield(info, infoFieldnamesParts{findPosInd}{2:end}, valueSet{ii}); %#ok<SFLD>            
            disp([infoFieldnames{findPosInd} ' changed successfully to:']);disp(valueSet{ii});      
        otherwise
            disp(infoFieldnames(1,findPosInd)');
            error(['Fieldname "' infoFieldnamesEndnodes{findPosInd(1)} '" is not unique, please re-run with full "structure-path" for this key (see list of possible values above)']);       
    end
end
end