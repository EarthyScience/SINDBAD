using JuliaFormatter
format(
    "../",
    MinimalStyle(),
    margin=200,
    always_for_in=true,
    for_in_replacement="∈",
    format_docstrings=true,
    yas_style_nesting=true,
    import_to_using=true,
    remove_extra_newlines=true,
    trailing_comma=false
)
