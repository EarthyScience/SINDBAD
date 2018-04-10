from pygraphviz import *
from numpy import *
#grph = gv.Digraph(format='png')#
#grph = gv.Digraph(format='pdf')#
grph=AGraph(directed=True,rankdir='LR',ratio = 'compress',size='2,1.8',nodesep=".54", ranksep="1.94",strict=False,overlap='false',rank='min')
#grph.attr(dpi='300',ratio = 'compress',size='1,0.8',rankdir='LR',rank = "max")
#grph.attr(dpi='300',ratio = 'compress',size='1,0.8')
#grph.attr()
#grph.attr()
#grph.attr(ratio = 'fill')
grph.node_attr.update(shape='record',color='#99cccc',fillcolor='#99dddd', style='rounded,filled')
#grph.node_attr.update(color='lightblue2', style='filled',fixedsize="true")
grph.graph_attr.update(pad="0.1", nodesep="0.5", ranksep="1.3")
grph.edge_attr.update(arrowhead='vee', arrowsize='1.1',color='#777777')
#aloo
def get_vals(_dict,_key):
    olist=[]
    for __key in _dict[_key]:
        olist=append(olist,__key)
    return(olist)
def set_node_atr(_nodes,colo='red'):
    for _node in _nodes:
        n=grph.get_node(_node)
        n.attr['color']=colo
        n.attr['fillcolor']=colo

f=file('callGraphSB.JSON')
node_list=[]
node_dic={}
nprev=''
for _fl in f.readlines():
    _fla=_fl.strip()
    if _fla[0] != '"':
            if '"Name"' in _fla:
#                print _fla
                nodename=_fla.split(':')[1].split('"')[1][:-2]
                grph.add_node(nodename)
                if nprev == '':
                    print '\\node [block] ('+nodename+') {'+nodename+'};'
                else:
                    print '\\node [block, below of='+nprev+'] ('+nodename+') {'+nodename+'};'
                nprev=nodename
#                print nodename
                node_dic[nodename]=[]
            if '"Source"' in _fla:
#                print "Source",_fla.split('"')
                node1=_fla.split('"')[3][:-2]
#                node_dic[node1]=append(node_dic[node1],node2)
                node2=_fla.split('"')[7][:-2]
                node_dic[node1]=append(node_dic[node1],node2)
                grph.add_edge(node1,node2)
                print '\\path [line] ('+node1+') -- ('+node2+');'
print node_dic.keys()

node_dic_full={}
for _node in node_dic.keys():

    if len(node_dic[_node]) > 0:
        vlist=get_vals(node_dic,_node)
        node_dic_full[_node]=vlist
        print _node,"going in",node_dic_full[_node]
    else:
        print "empty",_node

    print '--------'
    node_dic_full_2={}
ntry=1
while ntry < 20:
    for _parent in node_dic_full.keys():
        parents=node_dic_full.keys()
        childs=node_dic_full[_parent]
        print '------START---'
        print _parent,node_dic_full[_parent]
        for child in childs:
            if child in parents:
                for grandchild in node_dic_full[child]:
                    childs_new=node_dic_full[_parent]
                    if grandchild not in childs_new:
                        node_dic_full[_parent]= append(childs_new, grandchild)
                        print 'pr',_parent,'ch',child,'gc->',grandchild
        print _parent,node_dic_full[_parent]
        print '------END---'
    ntry=ntry+1
#    print '++++++++++++++++'
print node_dic_full['tem']
temList=node_dic_full['tem']
temSetupList=node_dic_full['temFullSetup']
common=list(set(temList).intersection(temSetupList))
print 'Yo Ho',common
set_node_atr(['tem'],colo='#99ff88')
set_node_atr(temList,colo='#99ff88')

set_node_atr(['temFullSetup'],colo='#99cccc')
set_node_atr(temSetupList,colo='#99cccc')
set_node_atr(common,colo='#ffdd66')
set_node_atr(['HowToRunTEM'],colo='#ff9988')
#n=grph.get_node(node_dic_full['tem'])

grph.graph_attr.update(overlap='false')
grph.graph_attr.update(fontsize='14')

grph.write("sindbad_flow.dot") # write to simple.dot

grph.draw('sindbad_flow.pdf',prog="dot") # draw to png using circo
#    \path [line] (init) -- (identify);

#                print node1,node2
