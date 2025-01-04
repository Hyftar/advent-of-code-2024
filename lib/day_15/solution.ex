defmodule Day15.Solution do
  def solve_question_1 do
    {map, moves} = get_data()

    moves
    |> Enum.reduce(map, &apply_move(&2, &1))
    |> tap(fn map -> print_map(map) |> IO.puts end)
    |> get_gps_coordinates_sum()
  end

  def solve_question_2 do
    nil
  end

  def apply_move(map, move) do
    push(
      map,
      find_robot_position(map),
      move
    )
  end

  def find_robot_position(map) do
    map
    |> Enum.find(fn {_position, char} -> char == "@" end)
    |> elem(0)
  end

  def apply_direction(position, direction, direction \\ :forward)

  def apply_direction({x, y}, direction, :backward) do
    case direction do
      "^" -> {x + 1, y}
      "v" -> {x - 1, y}
      ">" -> {x, y - 1}
      "<" -> {x, y + 1}
    end
  end

  def apply_direction({x, y}, direction, :forward) do
    case direction do
      "^" -> {x - 1, y}
      "v" -> {x + 1, y}
      ">" -> {x, y + 1}
      "<" -> {x, y - 1}
    end
  end

  def push(map, position, dir, step \\ 1)
  def push(map, _, _, 0), do: map
  def push(map, position, dir, step) do
    next_position = apply_direction(position, dir)

    case Map.get(map, next_position) do
      "#" -> map

      "." ->
        map
        |> swap(position, next_position)
        |> push(apply_direction(position, dir, :backward), dir, step - 1)

      "O" -> push(map, next_position, dir, step + 1)
    end
  end

  def swap(map, p1, p2) do
    %{ map | p1 => Map.get(map, p2), p2 => Map.get(map, p1) }
  end

  def print_map(map) do
    map
    |> Enum.sort()
    |> Enum.chunk_by(fn {{x, _}, _} -> x end)
    |> Enum.map(fn chunk -> Enum.map(chunk, fn {_, char} -> char end) |> Enum.join("") end)
    |> Enum.join("\n")
  end

  def get_gps_coordinates_sum(map) do
    map
    |> Enum.filter(fn {_position, char} -> char == "O" end)
    |> Enum.reduce(0, fn {{x, y}, _char}, acc -> acc + (100 * x + y) end)
  end

  def get_data do
    [map, moves] =
      File.read!("lib/day_15/input.txt")
      |> String.split("\n\n", trim: true)

    map =
      map
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))
      |> Enum.with_index()
      |> Enum.flat_map(
        fn {row, x} ->
          row
          |> Enum.with_index()
          |> Enum.map(fn {char, y} -> {{x, y}, char} end)
        end)
      |> Enum.into(Map.new())

    moves =
      moves
      |> String.split("\n", trim: true)
      |> Enum.flat_map(&String.split(&1, "", trim: true))

    {map, moves}
  end
end
