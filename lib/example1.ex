defmodule MWMExample1Module do

  import ExUnit.Assertions

  combine_plus_ast = quote do
    def combine_plus(x, y \\ 42) when is_number(x) and is_number(y) do
      x + y
    end
  end

  Code.eval_quoted(combine_plus_ast, [], __ENV__)

  # define the body code as a separate ast
  combine_list_body_ast = quote(do: x ++ y)
  # use unquote to "insert" the body ast into the function definition
  quote do
    def combine_list(x, y \\ [4,5,6]) when is_list(x) and is_list(y) do
      unquote(combine_list_body_ast)
    end
  end
  # and compile the function
  |> Code.eval_quoted([], __ENV__)

  combine_map_body_ast = quote(do: Map.merge(a, b))
  combine_map_ast = quote do
    def combine_map(x, y \\ %{d: 4}) when is_map(x) and is_map(y) do
      unquote(combine_map_body_ast)
    end
  end

  # edit the a & b vars to x & y
  combine_map_edit_ast = combine_map_ast
  |> Macro.postwalk(fn
    {:a, [], module} when is_atom(module) -> Macro.var(:x, __MODULE__)
    {:b, [], module} when is_atom(module) -> Macro.var(:y, __MODULE__)
    # passthru
    v -> v
  end)

  # and compile the function
  combine_map_edit_ast |> Code.eval_quoted([], __ENV__)

  # create stringifed code
  combine_map_stringified_ast = combine_map_edit_ast |> Macro.to_string

  # confirm stringifed code is as expected i.e. no a or b vars
  assert combine_map_stringified_ast  ==
  "def(combine_map(x, y \\\\ %{d: 4}) when is_map(x) and is_map(y)) do\n  Map.merge(x, y)\nend"
end
