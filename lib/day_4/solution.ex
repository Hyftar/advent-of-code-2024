defmodule Day4.Solution do
  def solve_question_1 do
    get_data()
    |> String.split("\n")
    |> Enum.map(
      fn x ->
        x
        |> String.trim()
        |> String.codepoints()
      end)
    |> rotations()
    |> Enum.map(fn x -> Enum.map(x, &Enum.join/1) end)
    |> Enum.map(fn x -> Enum.map(x, fn y -> Regex.scan(~r/XMAS/, y) |> length() end) |> Enum.sum() end)
    |> Enum.sum()
  end

  def solve_question_2 do
    matrix =
      get_data()
      |> String.split("\n")
      |> Enum.map(
        fn x ->
          x
          |> String.trim()
          |> String.codepoints()
        end)
      |> Enum.with_index()
      |> Enum.map(fn {x, i} -> Enum.with_index(x) |> Enum.map(fn {y, j} -> {j, y} end) |> Enum.into(Map.new()) |> then(fn y -> {i, y} end) end)
      |> Enum.into(Map.new())

    0..((matrix |> Map.keys() |> Enum.count()) - 1)
    |> Enum.map(
      fn i ->
        0..((matrix[i] |> Map.keys() |> Enum.count()) - 1)
        |> Enum.count(
          fn j ->
            get_diagonals(matrix, i, j)
            |> Enum.map(&Enum.join/1)
            |> Enum.count(fn x -> Regex.match?(~r/MAS|SAM/, x) end)
            |> then(fn x -> x == 2 end)
          end)
      end
    )
    |> Enum.sum()
  end

  def get_diagonals(matrix, middle_row, middle_col) do
    [
      [
        if middle_row > 0 && middle_col > 0 do matrix[middle_row - 1][middle_col - 1] else "" end,
        matrix[middle_row ][middle_col],
        if middle_row < ((matrix |> Map.keys() |> Enum.count()) - 1) && middle_col < (matrix[middle_row] |> Map.keys() |> Enum.count() )- 1 do matrix[middle_row + 1][middle_col + 1] else "" end
      ],
      [
        if middle_row < (matrix |> Map.keys() |> Enum.count()) - 1 && middle_col > 0 do matrix[middle_row + 1][middle_col - 1] else "" end,
        matrix[middle_row ][middle_col],
        if middle_row > 0 && middle_col < (matrix[middle_row] |> Map.keys() |> Enum.count()) - 1 do matrix[middle_row - 1][middle_col + 1] else "" end
      ]
    ]
  end

  def rotations(list) do
    [
      list,
      list |> deep_reverse(),
      list |> transpose(),
      list |> transpose() |> deep_reverse(),
      list |> rotate_45_degrees(),
      list |> rotate_45_degrees() |> deep_reverse(),
      list |> transpose() |> deep_reverse() |> rotate_45_degrees(),
      list |> transpose() |> deep_reverse() |> rotate_45_degrees() |> deep_reverse()
    ]
  end

  def transpose(list) do
    Enum.zip_with(list, &Function.identity/1)
  end

  def deep_reverse(list) do
    Enum.map(list, &Enum.reverse/1)
  end

  def rotate_45_degrees(list) do
    n = length(list)

    list
    |> Enum.with_index()
    |> Enum.flat_map(
      fn {a, x} ->
        a
        |> Enum.with_index()
        |> Enum.map(fn {b, y} -> {x + y, n - x + y - 1, b} end)
      end)
    |> Enum.sort_by(fn {x, _, _} -> x end)
    |> Enum.chunk_by(fn {x, _, _} -> x end)
    |> Enum.map(fn chunk -> Enum.sort_by(chunk, fn {_, y, _} -> y end) |> Enum.map(fn {_, _, z} -> z end) end)
  end

  def get_data do
    File.read!("lib/day_4/input.txt")
  end
end
