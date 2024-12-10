defmodule AdventOfCode2024 do
  def solve(day) do
    {
      run_with_timer(:"Elixir.Day#{day}.Solution", :solve_question_1, []),
      run_with_timer(:"Elixir.Day#{day}.Solution", :solve_question_2, [])
    }
  end

  def run_with_timer(module, function, args) do
    :timer.tc(module, function, args)
    |> then(fn {time, result} -> {result, "#{time / 1000}ms"} end)
  end
end
