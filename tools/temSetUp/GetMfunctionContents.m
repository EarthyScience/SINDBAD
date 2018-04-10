function [C]=GetMfunctionContents(mpth)

fid = fopen(mpth);
C = textscan(fid, '%s', 'delimiter', '?','CommentStyle','%'); %%check if mlint does extract the comments (2018-01-18)
fclose(fid);
C=C{1};

%check if last line is 'end' or 'return'; 

 if strncmp(C(end),'return',6) || strncmp(C(end),'end',3)
     C=C(2:end-1);
 else
     C=C(2:end);
 end

%C=C(2:end); %dirty!! ALWAYS assumes last line is and 'end' or 'return'

[pathstr,name,ext] = fileparts(mpth);

%find mfunctions in directory
mf=dir([pathstr filesep '*.m']);

%check if you find it in C
for ii=1:length(mf)
    %Comment: on Linux, the following line will only work for absolute paths
   [pathstr2,name,ext] = fileparts(mf(ii).name);

    tmp=regexp(C,[name '\s*(']); %added '(' to make sure its a function call and not e.g. confused with an error message
    
    for iii=1:length(tmp)
        
        if ~isempty(tmp{iii})
            %something found
            P1=C(1:iii-1);
            
            [P2]=GetMfunctionContents([pathstr filesep mf(ii).name]);
            
            P3=C(iii+1:end);
            C=vertcat(P1,P2,P3);
        end
        
    end
    
    
    
    
end

end