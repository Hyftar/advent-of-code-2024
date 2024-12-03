defmodule Day3.Solution do
  def solve_question_1 do
    get_data()
    |> then(&Regex.scan(~r/mul\((?<X>\d{1,3}),(?<Y>\d{1,3})\)/, &1))
    |> Enum.map(fn [_, x, y] -> {String.to_integer(x), String.to_integer(y)} end)
    |> Enum.reduce(0, fn {x, y}, acc -> acc + x * y end)
  end

  def solve_question_2 do
    get_data()
    |> then(&Regex.scan(~r/mul\((?<X>\d{1,3}),(?<Y>\d{1,3})\)|do\(\)|don't\(\)/, &1))
    |> Enum.reduce([0, "do()"], fn match, acc -> reducer(match, acc) end)
    |> hd()
  end

  def reducer([action], [sum, _] = _acc) do
    [sum, action]
  end

  def reducer([_, x, y], [sum, "do()"] = _acc) do
    {x, y} = {String.to_integer(x), String.to_integer(y)}
    [sum + x * y, "do()"]
  end

  def reducer([_, _, _], [sum, "don't()"] = _acc) do
    [sum, "don't()"]
  end

  defp get_data do
    File.read!("lib/day_3/input.txt")
  end
end
