defmodule Day16.Solution do
  require IEx

  def solve_question_1 do
    maze = get_data()

    start = find_start_coordinates(maze)
    end_coordinates = find_end_coordinates(maze)

    Map.put(maze, end_coordinates, ".")
    |> print_maze([start, end_coordinates])
  end

  def solve_question_2 do
    nil
  end

  def traverse_maze(maze, current_path \\ [])

  # def build_graph(_maze, {i, j, _dir}, {i, j}, graph, _current_path), do: graph
  def traverse_maze(maze, _) do

  end

  def get_options(maze, {i, j, dir} = _current_position) do
    case dir do
      :^ ->
        [
          if(Map.get(maze, {i - 1, j}) == ".", do: {{i - 1, j, :^}, 1}),
          if(Map.get(maze, {i, j - 1}) == ".", do: {{i, j - 1, :<}, 1001}),
          if(Map.get(maze, {i, j + 1}) == ".", do: {{i, j + 1, :>}, 1001})
        ]
      :> ->
        [
          if(Map.get(maze, {i, j + 1}) == ".", do: {{i, j + 1, :>}, 1}),
          if(Map.get(maze, {i - 1, j}) == ".", do: {{i - 1, j, :^}, 1001}),
          if(Map.get(maze, {i + 1, j}) == ".", do: {{i + 1, j, :v}, 1001})
        ]
      :< ->
        [
          if(Map.get(maze, {i, j - 1}) == ".", do: {{i, j - 1, :<}, 1}),
          if(Map.get(maze, {i - 1, j}) == ".", do: {{i - 1, j, :^}, 1001}),
          if(Map.get(maze, {i + 1, j}) == ".", do: {{i + 1, j, :v}, 1001})
        ]
      :v ->
        [
          if(Map.get(maze, {i + 1, j}) == ".", do: {{i + 1, j, :v}, 1}),
          if(Map.get(maze, {i, j - 1}) == ".", do: {{i, j - 1, :<}, 1001}),
          if(Map.get(maze, {i, j + 1}) == ".", do: {{i, j + 1, :>}, 1001})
        ]
    end
    |> Enum.filter(& &1)
  end

  def find_start_coordinates(maze) do
    maze
    |> Enum.find(fn {_position, char} -> char == "S" end)
    |> then(fn {{i, j}, _} -> {i, j, :>} end)
  end

  def find_end_coordinates(maze) do
    maze
    |> Enum.find(fn {_position, char} -> char == "E" end)
    |> then(fn {{i, j}, _} -> {i, j} end)
  end

  def print_maze(maze, highlight_positions \\ []) do
    maze
    |> Enum.sort()
    |> Stream.chunk_by(fn {{x, _}, _} -> x end)
    |> Stream.map(
      fn chunk ->
        chunk
        |> Stream.map(fn {pos, char} -> if pos in highlight_positions, do: IO.ANSI.green_background() <> char <> IO.ANSI.reset(), else: char end)
        |> Enum.join("")
      end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def shortest_path_weight(graph, start_position, end_position) do
    graph
    |> Graph.get_shortest_path(start_position, end_position)
    |> Stream.chunk_every(2, 1, :discard)
    |> Stream.map(fn [v1, v2] -> Graph.edge(graph, v1, v2).weight end)
    |> Enum.sum()
  end

  def get_data do
    File.read!("lib/day_16/input.test.txt")
    |> String.split("\n", trim: true)
    |> Stream.map(&String.split(&1, "", trim: true))
    |> Stream.with_index()
    |> Stream.flat_map(
      fn {line, i} ->
        line
        |> Stream.with_index()
        |> Enum.map(fn {char, j} -> {{i, j}, char} end)
      end
    )
    |> Enum.into(Map.new())
  end
end
