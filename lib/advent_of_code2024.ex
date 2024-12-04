defmodule AdventOfCode2024 do
  def solve(day) do
    {
      apply(:"Elixir.Day#{day}.Solution", :solve_question_1, []),
      apply(:"Elixir.Day#{day}.Solution", :solve_question_2, [])
    }
  end
end
