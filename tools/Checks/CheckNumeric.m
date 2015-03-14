function [NUMcheckFlag] = CheckNumeric(f,fe,fx,s,d,p,info)

%checks if variables are NaN, Inf or complex. it checks the variables
%provided in info.checks.bounds which can either be:
%'all': checks all variables
%a cellstr with e.g. {'f','fx'}
%a cellstr with variable names e.g. {'f.Rain','fx.Transp}
%or a combination of the latter two e.g. {'f','fx.Transp'}
%

%NUMcheckFlag is set to zero if any variable contains non finite or complex
%numbers
%warning messages are given for each variable which contains non finite or
%complex numbers
%warning messages are given if a certain desired variable does not exist

NUMcheckFlag=1;


allS={'f','fe','fx','s','d','p'};


if ~iscellstr(info.checks.numeric)
    if strcmp(info.checks.numeric,'all')
        %check all
        info.checks.numeric=allS;
    end
end

for ii=1:length(info.checks.numeric)
    
    cvnS=char(info.checks.numeric(ii));
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
            [NUMcheckFlag]=DoCheckNum(cvar,cvn,NUMcheckFlag);
            
        else
            %is a sinbad struct
            
            %get all fieldnames
            fnall=fieldnamesr(cvarS); %this one finds also names of substructures
            
            for jj=1:length(fnall)
                %get variable
                cvn=char(fnall(ii));
                eval(['cvar=' cvnS '.' cvn ';']);
                %do check
                [NUMcheckFlag]=DoCheckNum(cvar,cvn,NUMcheckFlag);
            end
            
        end
        
    catch
        mmsg=[cvn ' does not exist'];
        warning(mmsg)
    end
    
end



end



function [NUMcheckFlag]=DoCheckNum(cvar,cvn,NUMcheckFlag)

%checks variable cvar with name cvn for ok values (not NaN, Inf, complex)


%isfinite (catches NaN and Inf
%isreal (checks if there are complex numbers


vL=isfinite(cvar);
vioFrac = sum(sum(double(vL)))/numel(vL);
if vioFrac ~=0
    mmsg=[cvn ' contains NaN or Inf in ' num2str(vioFrac*100) ' % of cases'];
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





