defmodule Day11.Solution do
  def solve_question_1 do
    get_data()
    |> blink(0)
  end

  def solve_question_2 do
    nil
  end

  def blink(stones, 25), do: stones |> Enum.count
  def blink(stones, step) do
    stones
    |> Enum.reduce(
      [],
      fn stone, acc ->
        digits = digits_count(stone)
        cond do
          stone == 0 -> acc |> push(1)
          Bitwise.band(digits, 1) == 0 ->
            left_num = div(stone, trunc(:math.pow(10, digits / 2)))
            right_num = trunc(stone - left_num * :math.pow(10, :math.floor(digits / 2)))
            acc
            |> push(left_num)
            |> push(right_num)
          true -> acc |> push(stone * 2024)
        end
      end)
    |> blink(step + 1)
  end

  def get_data do
    File.read!("lib/day_11/input.txt")
    |> String.trim
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp push(list, elem), do: [elem | list]

  defp digits_count(0), do: 1
  defp digits_count(number) do
    number
    |> Kernel.abs
    |> :math.log10()
    |> :math.floor()
    |> then(&(&1 + 1))
    |> Kernel.trunc()
  end
end
