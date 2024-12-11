defmodule Day11.Solution do
  use Memoize

  def solve_question_1 do
    get_data()
    |> blink(25)
  end

  def solve_question_2 do
    get_data()
    |> blink(75)
  end

  def blink([_], 0), do: 1
  def blink([0], steps), do: blink([1], steps - 1)

  defmemo blink([stone], steps) do
    case should_split?(stone) do
      {true, split} -> blink(split, steps - 1)
      {false, _} -> blink([stone * 2024], steps - 1)
    end
  end

  defmemo blink([head | tail], steps) do
    blink([head], steps) + blink(tail, steps)
  end

  def should_split?(stone) do
    digits = digits_count(stone)

    digits
    |> Bitwise.band(1)
    |> Kernel.===(0)
    |> case do
      true -> {true, split(stone, digits)}
      false -> {false, nil}
    end
  end

  def get_data do
    File.read!("lib/day_11/input.txt")
    |> String.trim
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp digits_count(0), do: 1
  defp digits_count(number) do
    number
    |> Kernel.abs
    |> :math.log10()
    |> :math.floor()
    |> then(&(&1 + 1))
    |> Kernel.trunc()
  end

  defp split(stone, digits) do
    split =
      digits
      |> Kernel.div(2)
      |> Kernel.trunc()
      |> then(&(:math.pow(10, &1)))
      |> Kernel.trunc()

    [
      stone
      |> Kernel.div(split)
      |> Kernel.trunc(),
      stone
      |> Kernel.rem(split)
      |> Kernel.trunc()
    ]
  end
end
