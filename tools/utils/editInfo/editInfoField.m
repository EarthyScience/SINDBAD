function [info, subtree] = editInfoField(info, varargin)
% INPUT:    info       :    (info) structure
%           varargin{:}:	list of fields in info structure to change
%                           ('Fieldname' : new value) OR one string to
%                           search for in fieldnames (see examples)
% OUTPUT:   info : structure with changed (or unchanged) values
%           subtree : cell array with found fieldnames
%
% EXAMPLE 1:
% usage to change fieldvalues
%    - [info, subtree]	= editInfoField(info,'name',newValue);
%
% If the fieldname to change is not unique, the function issues a warning and all
% possible options can be accessed via output: subtree
% The function should the be rerun for this key(s) with the full unique structure path
% (e.g.: info.tem.model.modules.Qsnow.apprName)
%
% EXAMPLE 2:
% usage to look for substring in fieldnames
%       [info, subtree]	= editInfoField(info,'paths');

%% 1) Load, unfold and separate all fieldnames (endnodes) of Info structure
[infoFieldnames,~,infoFieldnamesPure] = getAllFieldnames(info,false,{},1);
%{
infoFieldnamesParts{1,size(infoFieldnames, 2)} = []; infoFieldnamesEndnodes{1,size(infoFieldnames, 2)} = [];
for ii = 1 : size(infoFieldnames, 2)
    infoFieldnamesParts{ii} = strsplit(infoFieldnames{ii}, '.');
    infoFieldnamesEndnodes(ii) = infoFieldnamesParts{ii}(1, end);
end
%}
infoFieldnamesParts{1,size(infoFieldnamesPure, 2)} = []; infoFieldnamesEndnodes{1,size(infoFieldnamesPure, 2)} = [];
for ii = 1 : size(infoFieldnamesPure, 2)
    infoFieldnamesParts{ii} = strsplit(infoFieldnamesPure{ii}, '.');
    infoFieldnamesEndnodes(ii) = infoFieldnamesParts{ii}(1, end);
end


%% 2) Check and read varargin
if nargin == 2 && numel(varargin) ~= 0
    findPosInd = strfind(infoFieldnames, varargin{1});
    findPosInd = ~cellfun('isempty',findPosInd);
    % disp(infoFieldnames(1,findPosInd)');
    subtree = infoFieldnames(1,findPosInd);
    return
elseif mod(nargin-1,2) == 0 %number is even else number is odd end
    keySet = varargin(1 : 2 : end);
    valueSet = varargin(2 : 2 : end);
else
    error('Number of arguments in varargin must to be even or 1 (or 0) as it represents a list of "Fieldname : newValue" pairs or a string to search for within the fieldnames.');
end
%% 3) Search for fieldnames which content is intended to change and change value or display information
subtree = cell(size(keySet));
for ii = 1 : size(keySet,2)
    if ~contains(cellstr(keySet(ii)),'.')
        findPosInd = strcmp(infoFieldnamesEndnodes, keySet{ii});
        no_of_occurences = sum(findPosInd);
    else
        findPosInd = strfind(infoFieldnames, keySet{ii});
        findPosInd = ~cellfun('isempty',findPosInd);
        no_of_occurences = sum(findPosInd);
    end
    
    switch no_of_occurences
        case 0
            error(['Fieldname "' keySet{ii} '" not found in Structure.']);
        case 1
            subtree{ii} = infoFieldnames(1,findPosInd);
            info = setfield(info, infoFieldnamesParts{findPosInd}{2:end}, valueSet{ii}); %#ok<SFLD>
                disp([pad('EDIT INFO FIELD',20) ' : ' pad('editInfoField',20) ' | ' infoFieldnamesPure{findPosInd} ' changed successfully to: ' toString(valueSet{ii})]);
        otherwise
            %disp(infoFieldnames(1,findPosInd)');
            subtree{ii} = infoFieldnames(1,findPosInd);
            disp([pad('WARN INFO FIELD',20) ' : ' pad('editInfoField',20) ' : Fieldname ' keySet{ii} ' is not unique. Re-run with full structure-path (e.g.,info.tem.model.flags.runOpti)'...
                'for this key (for list of possible values check 2nd output variable: subtree'])
            
    end
end
%% change spinup sequence if given as input. Added because the editTEMinfo does not work for struct array.
if any(strcmp(varargin,'info.tem.spinup.sequence'))% @nc : this seems inconsistent... should be tem.spinup.sequence ...
    disp([pad('WARN INFO EXCEPTION',20) ' : ' pad('editInfoField',20) ' : Fieldname info.tem.spinup.sequence is a struct array and it is flagged as multiple entries. Replacing the spinup sequence anyway!!'])
    datInd = find(strcmp(varargin,'info.tem.spinup.sequence'))+1 ;
    info.tem.spinup.sequence = varargin{datInd};
end
end
