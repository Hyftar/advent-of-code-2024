defmodule Day10.Solution do
  def solve_question_1 do
    traversal_map =
      get_data()
      |> create_traversal_map()

    traversal_map
    |> Enum.filter(fn {_, {cell, _}} -> cell == 0 end)
    |> Enum.flat_map(
      fn {coord, {cell, visited}} ->
        traverse(traversal_map, [coord], {coord, {cell, visited}})
      end)
    |> Enum.filter(&elem(&1, 1))
    |> Enum.uniq_by(
      fn {[last_coord, _, _, _, _, _, _, _, _, first_coord], _} -> {last_coord, first_coord} end
    )
    |> Enum.count
  end

  def solve_question_2 do
    traversal_map =
      get_data()
      |> create_traversal_map()

    traversal_map
    |> Enum.filter(fn {_, {cell, _}} -> cell == 0 end)
    |> Enum.flat_map(
      fn {coord, {cell, visited}} ->
        traverse(traversal_map, [coord], {coord, {cell, visited}})
      end)
    |> Enum.filter(&elem(&1, 1))
    |> Enum.count
  end

  def traverse(_map, previous, {_coord, {9, false}}), do: [{previous, true}]
  def traverse(traversal_map, previous, {coord, {current_cell, _visited}}, _opts \\ []) do
    target_next_cell = current_cell + 1
    next_map =
      traversal_map
      |> Map.update!(coord, fn {cell, _visited} -> {cell, true} end)

    deltas =
      get_deltas(coord)
      |> Enum.map(fn {dx, dy} -> {elem(coord, 0) + dx, elem(coord, 1) + dy} end)
      |> Enum.map(&({&1, Map.get(next_map, &1)}))
      |> Enum.filter(fn {_coord, content} -> match?({^target_next_cell, false}, content) end)

    if length(deltas) > 0 do
      deltas
      |> Enum.flat_map(fn {coord, {content, visited}} -> traverse(next_map, [coord | previous], {coord, {content, visited}}) end)
      |> Enum.filter(&elem(&1, 1))
    else
      [{previous, false}]
    end
  end

  def get_deltas({x, y}, max_x \\ 56, max_y \\ 56) do
    [
      {0,  1},
      {0, -1},
      {1,  0},
      {-1, 0}
    ]
    |> Enum.filter(fn {dx, dy} -> x + dx >= 0 and x + dx <= max_x and y + dy >= 0 and y + dy <= max_y end)
  end

  def create_traversal_map(map) do
    map
    |> Enum.with_index()
    |> Enum.reduce(
      %{},
      fn {line, i}, acc ->
        line
        |> Enum.with_index()
        |> Enum.reduce(
          acc,
          fn {cell, j}, acc ->
            Map.put(acc, {i, j}, {cell, false})
          end
        )
      end
    )
  end

  def get_data do
    File.read!("lib/day_10/input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(
      fn line ->
        line
        |> String.split("", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)
  end
end
