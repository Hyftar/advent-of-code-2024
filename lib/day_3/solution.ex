defmodule Day3.Solution do
  def solve_question_1 do
    get_data()
    |> then(&Regex.scan(~r/mul\((?<X>\d{1,3}),(?<Y>\d{1,3})\)/, &1))
    |> Enum.map(fn [_, x, y] -> {String.to_integer(x), String.to_integer(y)} end)
    |> Enum.reduce(0, fn {x, y}, acc -> acc + x * y end)
  end

  def solve_question_2 do
    nil
  end

  defp get_data do
    File.read!("lib/day_3/input.txt")
  end
end
