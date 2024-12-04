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
