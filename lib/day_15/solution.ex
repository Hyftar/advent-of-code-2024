defmodule Day15.Solution do
  def solve_question_1 do
    {map, moves} = get_data()

    moves
    |> Enum.reduce(map, &apply_move(&2, &1))
    |> get_gps_coordinates_sum()
  end

  def solve_question_2 do
    {map, moves} = get_data(expand: true)

    moves
    |> Enum.reduce(map, &apply_move(&2, &1, 2))
    |> get_gps_coordinates_sum()
  end

  def apply_move(map, move, part \\ 1)

  def apply_move(map, move, 1) do
    move(
      map,
      find_robot_position(map),
      move
    )
  end

  def apply_move(map, move, 2) when move in [">", "<"], do: apply_move(map, move, 1)

  def apply_move(map, move, 2) do
    {should_move, swaps} = move_part_2(map, find_robot_position(map), move)

    if should_move do
      swaps
      |> Enum.uniq()
      |> Enum.reduce(map, fn {from, to}, acc -> swap(acc, from, to) end)
    else
      map
    end
  end

  def find_robot_position(map) do
    map
    |> Enum.find(fn {_position, char} -> char == "@" end)
    |> elem(0)
  end

  def apply_direction(position, direction, direction \\ :forward)

  def apply_direction({x, y}, direction, :forward) do
    case direction do
      "^" -> {x - 1, y}
      "v" -> {x + 1, y}
      ">" -> {x, y + 1}
      "<" -> {x, y - 1}
    end
  end

  def apply_direction({x, y}, direction, :backward) do
    case direction do
      "^" -> {x + 1, y}
      "v" -> {x - 1, y}
      ">" -> {x, y - 1}
      "<" -> {x, y + 1}
    end
  end

  def move(map, position, dir, step \\ 1)
  def move(map, _, _, 0), do: map
  def move(map, position, dir, step) do
    next_position = apply_direction(position, dir)

    case Map.get(map, next_position) do
      "#" -> map

      "." ->
        map
        |> swap(position, next_position)
        |> move(apply_direction(position, dir, :backward), dir, step - 1)

      cell when cell in ["[", "]", "O"] -> move(map, next_position, dir, step + 1)
      end
  end

  def move_part_2(map, position, direction)

  def move_part_2(map, position, direction) do
    next_position = apply_direction(position, direction)
    cell = Map.get(map, next_position)

    case cell do
      "#" -> {false, []}
      "." -> {true, [{position, next_position}]}
      "[" ->
        [
          move_part_2(map, apply_direction(next_position, ">"), direction),
          move_part_2(map, next_position, direction)
        ]
        |> then(fn results -> {Enum.all?(results, &elem(&1, 0)), Enum.flat_map(results, &elem(&1, 1))} end)
        |> then(fn {should_move, swaps} -> {should_move, swaps ++ [{position, next_position}]} end)
      "]" ->
        [
          move_part_2(map, apply_direction(next_position, "<"), direction),
          move_part_2(map, next_position, direction)
        ]
        |> then(fn results -> {Enum.all?(results, &elem(&1, 0)), Enum.flat_map(results, &elem(&1, 1))} end)
        |> then(fn {should_move, swaps} -> {should_move, swaps ++ [{position, next_position}]} end)
    end
  end

  def swap(map, p1, p2) do
    %{ map | p1 => Map.get(map, p2), p2 => Map.get(map, p1) }
  end

  def print_map(map, highlight_positions \\ []) do
    map
    |> Enum.sort()
    |> Enum.chunk_by(fn {{x, _}, _} -> x end)
    |> Enum.map(
      fn chunk ->
        chunk
        |> Enum.map(fn {pos, char} -> if pos in highlight_positions, do: IO.ANSI.green_background() <> char <> IO.ANSI.reset(), else: char end)
        |> Enum.join("")
      end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def get_gps_coordinates_sum(map) do
    map
    |> Enum.filter(fn {_position, char} -> char in ["O", "["] end)
    |> Enum.reduce(0, fn {{x, y}, _char}, acc -> acc + (100 * x + y) end)
  end

  def get_data(opts \\ []) do
    [map, moves] =
      File.read!("lib/day_15/input.txt")
      |> String.split("\n\n", trim: true)

    map =
      map
      |> String.split("\n", trim: true)
      |> then(fn map -> if Keyword.get(opts, :expand), do: Enum.map(map, &expand_line/1), else: map end)
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

  def expand_line(line) do
    line
    |> String.replace("#", "##")
    |> String.replace("O", "[]")
    |> String.replace(".", "..")
    |> String.replace("@", "@.")
  end

  def debug(part \\ 1) do
    {map, _} = get_data(expand: true)

    loop(map, part)
  end

  def loop(map, part) do
    map
    |> print_map()
    |> IO.puts

    direction = IO.gets("Direction: ") |> String.trim("\n")

    if direction == "q" do
      :ok
    else
      map
      |> apply_move(direction, part)
      |> loop(part)
    end
  end
end
