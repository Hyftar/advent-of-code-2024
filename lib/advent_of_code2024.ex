defmodule AdventOfCode2024 do
  def solve(day) do
    Benchee.run(
      %{
        "Part 1" => fn -> apply(:"Elixir.Day#{day}.Solution", :solve_question_1, []) end,
        "Part 2" => fn -> apply(:"Elixir.Day#{day}.Solution", :solve_question_2, []) end
      }
    )
  end

  def run_with_timer(module, function, args) do
    :timer.tc(module, function, args)
    |> then(fn {time, result} -> {result, "#{time / 1000}ms"} end)
  end
end
