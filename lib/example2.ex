defmodule MWMExample2Helpers do
  # helper to apply a proxy dictionary in the
  # transformation of a template snippet
  defp helper_transform_template_snippet(template, proxy_dict)

  # simple atom
  defp helper_transform_template_snippet(n, proxy_dict) when is_atom(n) do
    case proxy_dict |> Map.has_key?(n) do
      true -> proxy_dict |> Map.get(n)
      _ -> n
    end
  end

  # simple var
  defp helper_transform_template_snippet({n, ctx, m}, proxy_dict)
  when is_atom(n) and is_atom(m) do
    case proxy_dict |> Map.has_key?(n) do
      true -> proxy_dict |> Map.get(n)
      _ -> {n, ctx, m}
    end
  end

  # fun call with args
  defp helper_transform_template_snippet({n, ctx, args}, proxy_dict)
  when (is_atom(n) or (is_tuple(n) and tuple_size(n) == 3))
  and is_list(args) do

    # fun_name may need transforming
    n = n |> helper_transform_template(proxy_dict)

    # apply proxies to the args
    args = args |> Enum.map(fn arg -> arg |> helper_transform_template(proxy_dict) end)

    # return the template with the transformed args
    {n, ctx, args}

  end

  # passthru
  defp helper_transform_template_snippet(n, _proxy_dict) do
    n
  end

  # main transform function
  def helper_transform_template(template, proxy_dict) when is_map(proxy_dict) do

    template
    |> helper_transform_template_snippet(proxy_dict)
    |> case do

         # no changes? => completely transformed
         ^template -> template

         # need to recurse until no further chnages
         new_template -> new_template |> helper_transform_template(proxy_dict)

       end

  end
end
defmodule MWMExample2Module do

  import MWMExample2Helpers

  combine_template_ast = quote do
    def fun_name(arg0, arg1 \\ arg1_default) when arg0_guard and arg1_guard do
      fun_body
    end
  end

  # edit the template with the dictionary
  postwalk_fun_generator = fn proxy_dict ->
    # return a function that embeds the proxy dictionary in the call
    # to helper_transform_template
    fn template -> template |> helper_transform_template(proxy_dict) end
  end

  combine_plus_proxies = %{
    fun_name: :combine_plus,
    fun_body: quote(do: x + y),
    arg0: Macro.var(:x, __MODULE__),
    arg1: Macro.var(:y, __MODULE__),
    arg1_default: 42,
    arg0_guard: quote(do: is_number(:arg0)),
    arg1_guard: quote(do: is_number(:arg1))}

  # edit the template with the dictionary
  combine_template_ast
  |> Macro.postwalk(postwalk_fun_generator.(combine_plus_proxies))
  # and compile the function
  |> Code.eval_quoted([], __ENV__)

  combine_list_proxies = %{
    fun_name: :combine_list,
    fun_body: quote(do: x ++ y),
    arg0: Macro.var(:x, __MODULE__),
    arg1: Macro.var(:y, __MODULE__),
    arg1_default: [4,5,6],
    arg0_guard: quote(do: is_list(:arg0)),
    arg1_guard: quote(do: is_list(:arg1))}

  # edit the template with the dictionary
  combine_template_ast
  |> Macro.postwalk(postwalk_fun_generator.(combine_list_proxies))
  # and compile the function
  |> Code.eval_quoted([], __ENV__)

  combine_map_proxies = %{
    fun_name: :combine_map,
    fun_body: quote(do: Map.merge(x, y)),
    arg0: Macro.var(:x, __MODULE__),
    arg1: Macro.var(:y, __MODULE__),
    arg1_default: %{d: 4} |> Macro.escape,
    arg0_guard: quote(do: is_map(:arg0)),
    arg1_guard: quote(do: is_map(:arg1))}

  # edit the template with the dictionary
  combine_template_ast
  |> Macro.postwalk(postwalk_fun_generator.(combine_map_proxies))
  # and compile the function
  |> Code.eval_quoted([], __ENV__)
end
