defmodule MWMExample1Test do
  use ExUnit.Case
  import MWMExample1Module
  assert 7 == combine_plus(5,2)
  assert 47 == combine_plus(5)
  assert_raise FunctionClauseError, fn ->
    combine_plus(1, :two)
  end
  assert [1,2,3] == combine_list([1], [2,3])
  assert [1,2,4,5,6] == combine_list([1,2])
  assert_raise FunctionClauseError, fn ->
    combine_list([1,2], 42)
  end
  assert Map.equal?(%{a: 1, b: 2, c: 3}, combine_map(%{a: 1}, %{b: 2, c: 3}))
  assert Map.equal?(%{a: 1, d: 4}, combine_map(%{a: 1}))
end
