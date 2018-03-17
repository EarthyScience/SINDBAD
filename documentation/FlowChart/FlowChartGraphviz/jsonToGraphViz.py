import graphviz as gv
#grph = gv.Digraph(format='png')#
#grph = gv.Digraph(format='pdf')#
#grph = gv.Digraph(format='pdf', engine='circo')
#grph = gv.Digraph(format='pdf', engine='neato')
grph = gv.Digraph(format='pdf', engine='fdp')
grph = gv.Digraph(format='pdf', engine='dot')

grph.attr(dpi='300',ratio = 'compress',size='1,0.8',rankdir='LR',rank = "max")
#grph.attr(dpi='300',ratio = 'compress',size='1,0.8')
#grph.attr()
#grph.attr()
#grph.attr(ratio = 'fill')
grph.node_attr.update(shape='record',color='#99cccc',fillcolor='#99dddd', style='rounded,filled')
#grph.node_attr.update(color='lightblue2', style='filled',fixedsize="true")
grph.graph_attr.update(pad="0.1", nodesep="0.5", ranksep="1.3")
grph.edge_attr.update(arrowhead='vee', arrowsize='1.1',color='#777777')
#aloo

f=file('callGraphSB.JSON')
nprev=''
for _fl in f.readlines():
    _fla=_fl.strip()
    if _fla[0] != '"':
            if '"Name"' in _fla:
#                print _fla
                nodename=_fla.split(':')[1].split('"')[1][:-2]
                grph.node(nodename)
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
                grph.edge(node1,node2)
                print '\\path [line] ('+node1+') -- ('+node2+');'
grph.graph_attr.update(overlap='false')
grph.graph_attr.update(fontsize='14')
grph.render('grph')
grph.view
#    \path [line] (init) -- (identify);

#                print node1,node2
