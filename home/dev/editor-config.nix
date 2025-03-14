{ stableLib, ... }:

let

settings = {
    "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        indent_style = "space";
        indent_size = 4;
    };
    "*.cs" = {
        # Newline settings
        csharp_new_line_before_open_brace = "none";
        csharp_new_line_before_else = false;
        csharp_new_line_before_catch = false;
        csharp_new_line_before_finally = false;
        csharp_new_line_before_members_in_object_initializers = false;
        csharp_new_line_before_members_in_anonymous_types = false;
        csharp_new_line_between_query_expression_clauses = false;

        # Indentation preferences
        csharp_indent_block_contents = true;
        csharp_indent_braces = false;
        csharp_indent_case_contents = true;
        csharp_indent_case_contents_when_block = true;
        csharp_indent_switch_labels = true;
        csharp_indent_labels = "flush_left";

        # Whitespace options
        csharp_style_allow_embedded_statements_on_same_line_experimental = false;
        csharp_style_allow_blank_lines_between_consecutive_braces_experimental = false;
        csharp_style_allow_blank_line_after_colon_in_constructor_initializer_experimental = false;
        csharp_style_allow_blank_line_after_token_in_conditional_expression_experimental = false;
        csharp_style_allow_blank_line_after_token_in_arrow_expression_clause_experimental = false;

        # Prefer "var" everywhere
        csharp_style_var_for_built_in_types = "true:suggestion";
        csharp_style_var_when_type_is_apparent = "true:suggestion";
        csharp_style_var_elsewhere = "true:suggestion";

        # Prefer method-like constructs to have a block body
        csharp_style_expression_bodied_methods = "false:none";
        csharp_style_expression_bodied_constructors = "false:none";
        csharp_style_expression_bodied_operators = "false:none";

        # Prefer property-like constructs to have an expression-body
        csharp_style_expression_bodied_properties = "true:none";
        csharp_style_expression_bodied_indexers = "true:none";
        csharp_style_expression_bodied_accessors = "true:none";

        # Suggest more modern language features when available
        csharp_style_pattern_matching_over_is_with_cast_check = "true:suggestion";
        csharp_style_pattern_matching_over_as_with_null_check = "true:suggestion";
        csharp_style_inlined_variable_declaration = "true:suggestion";
        csharp_style_throw_expression = "true:suggestion";
        csharp_style_conditional_delegate_call = "true:suggestion";
        csharp_style_prefer_extended_property_pattern = "true:suggestion";

        # Space preferences
        csharp_space_after_cast = true;
        csharp_space_after_colon_in_inheritance_clause = true;
        csharp_space_after_comma = true;
        csharp_space_after_dot = false;
        csharp_space_after_keywords_in_control_flow_statements = true;
        csharp_space_after_semicolon_in_for_statement = true;
        csharp_space_around_binary_operators = "before_and_after";
        csharp_space_around_declaration_statements = "do_not_ignore";
        csharp_space_before_colon_in_inheritance_clause = true;
        csharp_space_before_comma = false;
        csharp_space_before_dot = false;
        csharp_space_before_open_square_brackets = false;
        csharp_space_before_semicolon_in_for_statement = false;
        csharp_space_between_empty_square_brackets = false;
        csharp_space_between_method_call_empty_parameter_list_parentheses = false;
        csharp_space_between_method_call_name_and_opening_parenthesis = false;
        csharp_space_between_method_call_parameter_list_parentheses = false;
        csharp_space_between_method_declaration_empty_parameter_list_parentheses = false;
        csharp_space_between_method_declaration_name_and_open_parenthesis = false;
        csharp_space_between_method_declaration_parameter_list_parentheses = false;
        csharp_space_between_parentheses = false;
        csharp_space_between_square_brackets = false;

        # Blocks are allowed
        csharp_prefer_braces = "true:silent";
        csharp_preserve_single_line_blocks = true;
        csharp_preserve_single_line_statements = true;
    };
};

in

{
    home.file."code/.editorconfig".text = stableLib.generators.toINIWithGlobalSection { } {
        globalSection = { root = true; };
        sections = settings;
    };
}
