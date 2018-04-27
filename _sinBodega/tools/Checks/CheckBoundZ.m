function [BNDcheckFlag] = CheckBoundZ(f,fe,fx,s,d,p,info)

%checks if variables are within predefined bounds. it checks the variables
%provided in info.checks.bounds which can either be:
%'all': checks all variables
%a cellstr with e.g. {'f','fx'}
%a cellstr with variable names e.g. {'f.Rain','fx.Transp}
%or a combination of the latter two e.g. {'f','fx.Transp'}
%
%bounds are assumed to be given in info.variables.bounds which is a cellarray with:
%1st col: variable name (e.g. f.Rain)
%2nd col: lower bound
%3rd col: upper bound

%BNDcheckFlag is set to zero if any variable exceeds bounds in at least one
%case
%warning messages are given for each variable that violate bounds
%warning messages are given if no bounds are provided for a desired variable
%warning messages are given if a certain desired variable does not exist

BNDcheckFlag=1;


allS={'f','fe','fx','s','d','p'};

%variable names for which we have bounds
vnB=cellstr(info.variables.bounds(:,1));
%lower and upper bounds
LB=NaN(size(vnB));
UB=NaN(size(vnB));

%convert from cell to matrix
for ii=1:length(vnB)
    %for some strange reason we seem to need to loop here to correctly
    %recongise 'Inf'
    LB(ii)=str2double(cell2mat(info.variables.bounds(ii,2)));
    UB(ii)=str2double(cell2mat(info.variables.bounds(ii,3)));
end

if ~iscellstr(info.checks.bounds)
    if strcmp(info.checks.bounds,'all')
        %check all        
        info.checks.bounds=allS;        
    end
end

for ii=1:length(info.checks.bounds)
    
    cvnS=char(info.checks.bounds(ii));
    try
        %get variable
        eval(['cvarS=' cvnS ';']);
        
        %check if it's a sindbad struct
        vs=find(strcmp(cvarS,allS));
        
        if isempty(vs)
            %is a variable
            cvn=cvnS;
            cvar=cvarS;
            
            %do check
            [BNDcheckFlag]=DoBNDcheck(cvar,cvn,vnB, LB,UB,BNDcheckFlag);
            
        else
            %is a sinbad struct
            
            %get all fieldnames
            fnall=fieldnamesr(cvarS); %this one finds also names of substructures
            
            for jj=1:length(fnall)
                %get variable
                cvn=char(fnall(ii));
                eval(['cvar=' cvnS '.' cvn ';']);
                %do check
                [BNDcheckFlag]=DoBNDcheck(cvar,cvn,vnB, LB,UB,BNDcheckFlag);
            end
            
        end
        
    catch
        mmsg=[cvn ' does not exist'];
        warning(mmsg)
    end
    
end



end


function [BNDcheckFlag]=CheckBND(cvar,cvn, cLB,cUB,BNDcheckFlag)

%check lower bound
vL=cvar < cLB;
vioFrac = sum(sum(double(vL)))/numel(vL);
if vioFrac ~=0
    mmsg=[cvn ' smaller than lower bound (' num2str(cLB) ') in ' num2str(vioFrac*100) ' % of cases'];
    warning(mmsg);
    BNDcheckFlag=0;
end

%check upper bound
vL=cvar > cUB;
vioFrac = sum(sum(double(vL)))/numel(vL);
if vioFrac ~=0
    mmsg=[cvn ' larger than upper bound (' num2str(cUB) ') in ' num2str(vioFrac*100) ' % of cases'];
    warning(mmsg);
    BNDcheckFlag=0;
end


end

function [BNDcheckFlag]=DoBNDcheck(cvar,cvn,vnB, LB,UB,BNDcheckFlag)

%find bound
v=find(strcmp(cvn,vnB));
if ~isempty(v)
    cLB=LB(v);
    cUB=UB(v);
    
    %do Check
    [BNDcheckFlag]=CheckBND(cvar,cvn, cLB,cUB,BNDcheckFlag);
else
    
    mmsg=['No bounds for ' cvn ];
    warning(mmsg)
    
end

end



