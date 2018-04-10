function [f,fe,fx,s,d,p]=IniDummyVariables4Test(info,ntime,nspace);


pthModules=info.paths.Modules;
pthPrecsGen=info.paths.PrecGen;



[FullMatrix,AllVars,FunNames,Matchmatrix]=FindAllVariablesInAllFunctions(pthModules,pthPrecsGen);


dummy1=rand(nspace,ntime);
dummy2=rand(nspace,1);

f=struct;
fe=struct;
fx=struct;
s=struct;
d=struct;
p=struct;

for i=1:length(AllVars)
   if strncmp('p.',AllVars(i),2)
       
       eval([char(AllVars(i)) '=dummy2;']);
       
   else
       eval([char(AllVars(i)) '=dummy1;']);
   end
    
    
    
end

end