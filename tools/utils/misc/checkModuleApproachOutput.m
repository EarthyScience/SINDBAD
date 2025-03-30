function oc = checkModuleApproachOutput(m)
bd = [sindbadroot 'model/modules/' m '/'];
sd = dir(bd);
oc = struct;
for i = 3:numel(sd)
    fs = rdir([bd sd(i).name '\*' m '_*.m']);
    oc.(sd(i).name) =    {};
    for j = 1:numel(fs)
        codeStruct = getCodeMfile([fs(j).name]);
        if isfield(codeStruct,'funOutput')
            oc.(sd(i).name) = [oc.(sd(i).name) codeStruct.funOutput'];
        end
    end
    oc.(sd(i).name) = sort(unique(oc.(sd(i).name) ));
    
end
end