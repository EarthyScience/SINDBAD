function [SBvariables_problem]=Check_numeric(f,fe,fx,s,d,p,SBvariables)

%checks all variables for ok values (not NaN, Inf, complex)


%isfinite (catches NaN and Inf
%isreal (checks if there are complex numbers

SBvariables_problem={[]};
cnt=1;
for i=1:length(SBvariables)
   
    eval(['a=isfinite(' char(SBvariables(i)) ');']);
    eval(['b=isreal(' char(SBvariables(i)) ');']);
    
    if sum(find(a==0))>0 || b==0
        SBvariables_problem(cnt)=SBvariables(i);
        cnt=cnt+1;
    end
    
    
    
end

end