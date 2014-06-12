function [precs]=GatherXLSfiles(xpth,precs,cnt)

%xlsfile contents
[num,txt,raw]=xlsread(xpth,'Input');
tf=strcmp('VariableName',raw(1,:));
precs(cnt).Input=raw(2:end,tf);

[num,txt,raw]=xlsread(xpth,'Output');
tf=strcmp('VariableName',raw(1,:));
precs(cnt).Output=raw(2:end,tf);

ps=struct;
[num,txt,raw]=xlsread(xpth,'Params');
tf=strcmp('VariableName',raw(1,:));
ps.Names=raw(2:end,tf);
tf=strcmp('Default',raw(1,:));
ps.Default=raw(2:end,tf);
tf=strcmp('LowerBound',raw(1,:));
ps.LowerBound=raw(2:end,tf);
tf=strcmp('UpperBound',raw(1,:));
ps.UpperBound=raw(2:end,tf);
precs(cnt).params=ps;
end