defmodule Day1.Solution do
  def solve_question_1 do
    col1 = parse_col(0) |> Enum.sort()
    col2 = parse_col(1) |> Enum.sort()

    col1
    |> Enum.zip(col2)
    |> Enum.map(fn {a, b} -> Kernel.abs(a - b) end)
    |> Enum.sum()
  end

  def solve_question_2 do
    col1 = parse_col(0)
    col2 = parse_col(1)

    count_map = build_count_map(col1, col2)

    col1
    |> Enum.map(&(&1 * count_map[&1]))
    |> Enum.sum()
  end

  def build_count_map(col1, col2) do
    col1
    |> Enum.uniq()
    |> Enum.map(&({&1, Enum.count(col2, fn y -> y == &1 end)}))
    |> Map.new()
  end

  def parse_col(col_index) do
    File.stream!("lib/day_1/input.csv")
    |> CSV.decode!(separator: ?,, trim: true, headers: false)
    |> Enum.map(&Enum.at(&1, col_index))
    |> Enum.map(fn elem -> String.to_integer(elem) end)
  end
end
