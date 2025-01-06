defmodule Day16.Solution do
  alias Utils.PriorityQueue
  alias Utils.Dijkstra

  def solve_question_1 do
    get_data()
    |> then(fn maze ->
      PriorityQueue.new()
      |> PriorityQueue.push({{0, 1}, [find_start_coordinates(maze)]}, 0)
      |> Dijkstra.dijkstra(
        build_graph(maze),
        find_end_coordinates(maze)
      )
    end)
  end

  def solve_question_2 do
    get_data()
    |> then(fn maze ->
      {_, min_score} =
        PriorityQueue.new()
        |> PriorityQueue.push({{0, 1}, [find_start_coordinates(maze)]}, 0)
        |> Dijkstra.dijkstra(
          build_graph(maze),
          find_end_coordinates(maze)
        )

      PriorityQueue.new()
      |> PriorityQueue.push({{0, 1}, [find_start_coordinates(maze)]}, 0)
      |> Dijkstra.dijkstra_combined_path(build_graph(maze), find_end_coordinates(maze), min_score)
      |> MapSet.size()
    end)
  end

  def build_graph(maze) do
    maze
    |> Enum.filter(fn {{i, j}, char} ->
      cv = Enum.count([{i - 1, j}, {i + 1, j}], &maze[&1])
      ch = Enum.count([{i, j - 1}, {i, j + 1}], &maze[&1])

      (cv > 0 and ch > 0) or (char in [?S, ?E])
    end)
    |> Enum.map(&elem(&1, 0))
    |> Map.new(&{&1, []})
    |> seed_neighbors(maze)
  end

  def seed_neighbors(graph, maze) do
    graph
    |> Enum.reduce(%{}, fn {{i, j}, _}, g ->
      north_neighbors =
        {i - 1, j}
        |> Stream.iterate(fn {i2, j2} -> {i2 - 1, j2} end)
        |> Stream.take_while(&maze[&1])
        |> Enum.find(&graph[&1])

      south_neighbors =
        {i + 1, j}
        |> Stream.iterate(fn {i2, j2} -> {i2 + 1, j2} end)
        |> Stream.take_while(&maze[&1])
        |> Enum.find(&graph[&1])

      west_neighbors =
        {i, j - 1}
        |> Stream.iterate(fn {i2, j2} -> {i2, j2 - 1} end)
        |> Stream.take_while(&maze[&1])
        |> Enum.find(&graph[&1])

      east_neighbors =
        {i, j + 1}
        |> Stream.iterate(fn {i2, j2} -> {i2, j2 + 1} end)
        |> Stream.take_while(&maze[&1])
        |> Enum.find(&graph[&1])

      neighbors =
        [north_neighbors, south_neighbors, west_neighbors, east_neighbors]
        |> Enum.reject(&is_nil/1)
        |> Enum.filter(&graph[&1])

      Map.put(g, {i, j}, neighbors)
    end)
  end

  def find_start_coordinates(maze), do: Enum.find(maze, fn {_, char} -> char == ?S end) |> elem(0)
  def find_end_coordinates(maze), do: Enum.find(maze, fn {_, char} -> char == ?E end) |> elem(0)

  def get_data do
    File.read!("lib/day_16/input.txt")
    |> String.split("\n", trim: true)
    |> Stream.map(&String.to_charlist/1)
    |> Stream.with_index()
    |> Stream.flat_map(
      fn {line, i} ->
        line
        |> Stream.with_index()
        |> Enum.map(fn {char, j} -> {{i, j}, char} end)
      end
    )
    |> Stream.filter(fn {_, char} -> char in [?., ?S, ?E] end)
    |> Enum.into(Map.new())
  end
end
