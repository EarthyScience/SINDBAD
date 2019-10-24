dataMat=load('/Net/Groups/BGI/work_3/sindbad/data/testBeds/NH/NH.mat');
fn=fieldnames(dataMat);
dataMato=struct;
for nn = 1:numel(fn)
    inda=dataMat.(fn{nn});
    dataMato.(fn{nn})=inda(1:25,:);
end