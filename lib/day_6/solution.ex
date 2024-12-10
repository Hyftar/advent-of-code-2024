defmodule Day6.Solution do
  require IEx

  def solve_question_1 do
    matrix = get_data()

    {{start_y, start_x}, "^"} = Enum.find(matrix, &match?({_, "^"}, &1))

    {updated_matrix, _visited} = traverse(matrix, {start_y, start_x})

    1 + Enum.count(updated_matrix, &match?({_, "X"}, &1))
  end

  def solve_question_2 do
    matrix = get_data()

    {{start_y, start_x}, "^"} = Enum.find(matrix, &match?({_, "^"}, &1))

    {_updated_matrix, visited} = traverse(matrix, {start_y, start_x})

    visited
    |> Enum.filter(&(&1 != {start_y, start_x}))
    |> Enum.reduce(0, fn {obstacle_y, obstacle_x}, acc ->
      modified_matrix = Map.put(matrix, {obstacle_y, obstacle_x}, "O")

      case traverse(modified_matrix, {start_y, start_x}) do
        :loop -> acc + 1
        _ -> acc
      end
    end)
  end

  defp traverse(matrix, {start_y, start_x}) do
    0
    |> Stream.iterate(&(&1 + 1))
    |> Enum.reduce_while({matrix, {start_y, start_x}, MapSet.new()}, fn _, {matrix, {y, x}, visited} ->
      {{d_y, d_x}, current, rotated} =
        case matrix[{y, x}] do
          "^" -> {{-1, 0}, "^", ">"}
          ">" -> {{0, 1}, ">", "v"}
          "v" -> {{1, 0}, "v", "<"}
          "<" -> {{0, -1}, "<", "^"}
        end

      if MapSet.member?(visited, {{y, x}, current}) do
        {:halt, :loop}
      else
        updated_visited = MapSet.put(visited, {{y, x}, current})

        case matrix[{y + d_y, x + d_x}] do
          char when char == "#" or char == "O" ->
            updated_matrix = Map.put(matrix, {y, x}, rotated)

            {:cont, {updated_matrix, {y, x}, updated_visited}}

          char when char == "." or char == "X" ->
            updated_matrix = matrix |> Map.put({y, x}, "X") |> Map.put({y + d_y, x + d_x}, current)

            {:cont, {updated_matrix, {y + d_y, x + d_x}, updated_visited}}

          nil ->
            {:halt, {matrix, MapSet.new(updated_visited, &elem(&1, 0))}}
        end
      end
    end)
  end

  def get_data do
    matrix =
      File.read!("lib/day_6/input.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    for {row, i} <- Enum.with_index(matrix), reduce: %{} do
      acc ->
        for {char, j} <- Enum.with_index(row), reduce: acc do
          acc ->
            Map.put(acc, {i, j}, char)
        end
    end
  end

  def print_map(map) do
    map
    |> Enum.map(fn x -> Enum.join(x, "") end)
    |> Enum.join("\n")
    |> IO.puts()
  end
end
