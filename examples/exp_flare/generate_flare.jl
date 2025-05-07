
"""
    namedTupleToFlareJSON(info::NamedTuple)

Convert a nested NamedTuple into a flare.json format suitable for d3.js visualization.

# Arguments
- `info::NamedTuple`: The input NamedTuple to convert

# Returns
- A dictionary in flare.json format with the following structure:
  ```json
  {
    "name": "root",
    "children": [
      {
        "name": "field1",
        "children": [...]
      },
      {
        "name": "field2",
        "value": 42
      }
    ]
  }
  ```

# Notes
- The function recursively traverses the NamedTuple structure
- Fields with no children are treated as leaf nodes with a value of 1
- The structure is flattened to show the full path to each field
"""
function namedTupleToFlareJSON(info::NamedTuple)
    function _convert_to_flare(nt::NamedTuple, name="sindbad_info")
        children = []
        for field in propertynames(nt)
            value = getfield(nt, field)
            if value isa NamedTuple
                push!(children, _convert_to_flare(value, string(field)))
            else
                # println("field: $field, value: $value")
                push!(children, Dict("name" => string(field), "value" => 1))
            end
        end
        return Dict("name" => name, "children" => children)
    end
    
    return _convert_to_flare(info)
end


using SindbadExperiment

info = getExperimentInfo("../exp_flare/settings_flare/experiment.json"); 


flare_json = namedTupleToFlareJSON(info)

open(joinpath(@__DIR__,"sindbad_info.json"), "w") do f
    SindbadSetup.json_print(f, flare_json)
end