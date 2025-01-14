defmodule Day7.Solution do
  def solve_question_1 do
    get_data()
    |> Enum.map(
      fn {target, [first | rest]} -> traverse(1, target, first, rest) end
    )
    |> Enum.filter(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def solve_question_2 do
    get_data()
    |> Enum.map(
      fn {target, [first | rest]} -> traverse(2, target, first, rest) end
    )
    |> Enum.filter(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def traverse(_part, target, current, _coeffiecients) when current > target, do: {false, target}
  def traverse(_part, target, current, [] = _coeffiecients), do: {target == current, target}
  def traverse(part, target, current, [a | rest] = _coeffiecients) do
    with {false, _} <- traverse(part, target, current * a, rest),
        {false, _} <- traverse(part, target, current + a, rest)
    do
      if part == 2 do
        traverse(part, target, concat_numbers(current, a), rest)
      else
        {false, target}
      end
    end
  end

  def get_data do
    File.read!("lib/day_7/input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ": ", trim: true))
    |> Enum.map(
      fn [x, y] ->
        {
          String.to_integer(x),
          y
          |> String.split(" ", trim: true)
          |> Enum.map(&String.to_integer/1)
        }
      end)
  end

  def concat_numbers(a, b) do
    (Integer.to_string(a) <> Integer.to_string(b))
    |> String.to_integer
  end
end
