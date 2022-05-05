using Sinbad
import JSON
import DataStructures
fconfig = "./sandbox/test_json/settings_minimal/modelStructure.json"
jsonFile = String(JSON.read(fconfig))
parseFile = JSON.parse(jsonFile; dicttype=DataStructures.OrderedDict)
parseFile["pools"]["carbon"]["pools"]
#parseFile["pools"]["water"]["pools"]