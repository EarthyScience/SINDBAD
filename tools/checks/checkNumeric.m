function [numericCheckFlag] = checkNumeric(f,fe,fx,s,d,p,info)

% checks if variables are NaN, Inf or complex. it checks the variables
% provided in tem.model.variables.to.check which can either be:
% 'all': checks all variables
% a cellstr with e.g. {'f','fx'}
% a cellstr with variable names e.g. {'f.Rain','fx.tranAct}
% or a combination of the latter two e.g. {'f','fx.tranAct'}
% ONLY if info.tem.model.flags.checks.numeric = true

% NUMcheckFlag is set to zero if any variable contains non finite or complex numbers
% warning messages are given for each variable which contains non finite or complex numbers
% warning messages are given if a certain desired variable does not exist

if info.tem.model.flags.checks.numeric == true
    
    numericCheckFlag = 1;
 
    allS = {'f','fe','fx','s','d','p'};
    
    if ~iscellstr(info.tem.model.variables.to.check)
        if strcmp(info.tem.model.variables.to.check,'all')
            %check all
            info.tem.model.variables.to.check=allS;
        end
    end
    
    for ii=1:length(info.tem.model.variables.to.check)
        
        cvnS = char(info.tem.model.variables.to.check(ii));
        try
            %get variable
            eval(['cvarS=' cvnS ';']);
            
            %check if it's a sindbad struct
            vs = find(strcmp(cvarS,allS));
            
            if isempty(vs)
                %is a variable
                cvn     = cvnS;
                cvar    = cvarS;
                
                %do check
                [numericCheckFlag] = DoCheckNum(cvar,cvn,numericCheckFlag);
                
            else
                %is a sinbad struct
                
                %get all fieldnames
                fnall = fieldnamesr(cvarS); %this one finds also names of substructures
                
                for jj=1:length(fnall)
                    %get variable
                    cvn = char(fnall(ii));
                    eval(['cvar=' cvnS '.' cvn ';']);
                    %do check
                    [numericCheckFlag] = DoCheckNum(cvar,cvn,numericCheckFlag);
                end
                
            end
            
        catch
            mmsg = [cvn ' does not exist'];
            warning(mmsg)
        end
        
    end
    
end

end



function [NUMcheckFlag]=DoCheckNum(cvar,cvn,NUMcheckFlag)
%checks variable cvar with name cvn for ok values (not NaN, Inf, complex)

%isfinite (catches NaN and Inf
%isreal (checks if there are complex numbers


vL = isfinite(cvar);
vioFrac = sum(sum(double(vL)))/numel(vL);
if vioFrac ~=0
    mmsg = [cvn ' contains NaN or Inf in ' num2str(vioFrac*100) ' % of cases'];
    warning(mmsg);
    NUMcheckFlag=0;
end

vL=isreal(cvar);
vioFrac = sum(sum(double(vL)))/numel(vL);
if vioFrac ~=0
    mmsg=[cvn ' contains complex in ' num2str(vioFrac*100) ' % of cases'];
    warning(mmsg);
    NUMcheckFlag=0;
end




end





