f=file('callGraphSB.JSON')
nprev=''
for _fl in f.readlines():
    _fla=_fl.strip()
    if _fla[0] != '"':
            if '"Name"' in _fla:
#                print _fla
                nodename=_fla.split(':')[1].split('"')[1][:-2]
                if nprev == '':
                    print '\\node [block] ('+nodename+') {'+nodename+'};'
                else:
                    print '\\node [block, below of='+nprev+'] ('+nodename+') {'+nodename+'};'
                nprev=nodename
#                print nodename
            if '"Source"' in _fla:
#                print "Source",_fla.split('"')
                node1=_fla.split('"')[3][:-2]
                node2=_fla.split('"')[7][:-2]
                print '\\path [line] ('+node1+') -- ('+node2+');'
#    \path [line] (init) -- (identify);

#                print node1,node2
