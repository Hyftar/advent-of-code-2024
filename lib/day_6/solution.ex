defmodule Day6.Solution do
  require IEx

  def solve_question_1 do
    map = get_data()

    initial_guard_position = find_guard_position(map)
    simulate(
      map,
      initial_guard_position,
      get_element(map, initial_guard_position)
    )
    |> tap(fn map -> map |> Enum.map(&Enum.join(&1, "")) |> Enum.join("\n") |> IO.puts() end)
    |> Enum.map(fn line -> Enum.count(line, fn x -> x == "X" end) end)
    |> Enum.sum()
  end

  def solve_question_2 do
    map = get_data()

    initial_guard_position = find_guard_position(map)

    0..(length(map) - 1)
    |> Enum.flat_map(
      fn x ->
        0..(length(hd(map)) - 1)
        |> Enum.map(&({x, &1}))
      end)
    |> Enum.filter(&(&1 != initial_guard_position))
    |> Enum.map(
      fn block_position ->
        IO.write(".")
        map
        |> set_element(block_position, "O")
        |> check_loop(initial_guard_position, get_element(map, initial_guard_position), block_position, 0)
      end)
    |> Enum.uniq_by(fn {_, block_position} -> block_position end)
    |> Enum.count(fn {result, _} -> result end)
  end

  defp simulate(map, {0, _} = guard_position, "^"), do: set_element(map, guard_position, "X")
  defp simulate(map, {x, _} = guard_position, "v") when x == length(map) - 1, do: set_element(map, guard_position, "X")
  defp simulate(map, {_, 0} = guard_position, "<"), do: set_element(map, guard_position, "X")
  defp simulate(map, {_, y} = guard_position, ">") when y == ((hd(map) |> length()) - 1), do: set_element(map, guard_position, "X")
  defp simulate(map, {x, y} = guard_position, direction) do
    rotate = get_element(map, {x, y}, direction) == "#"
    {new_direction, next_position} = get_next_guard_position(direction, guard_position, rotate)

    map
    |> set_element(guard_position, "X")
    |> set_element(next_position, new_direction)
    |> simulate(next_position, new_direction)
  end

  defp check_loop(_map, {0, _} = _guard_position, "^", tentative_block_position, _step), do: {false, tentative_block_position}
  defp check_loop(map, {x, _} = _guard_position, "v", tentative_block_position, _step) when x == length(map) - 1, do: {false, tentative_block_position}
  defp check_loop(_map, {_, 0} = _guard_position, "<", tentative_block_position, _step), do: {false, tentative_block_position}
  defp check_loop(map, {_, y} = _guard_position, ">", tentative_block_position, _step) when y == ((hd(map) |> length()) - 1), do: {false, tentative_block_position}
  defp check_loop(map, {x, y} = guard_position, direction, tentative_block_position, step) do
    next_cell =
      get_next_guard_position(direction, guard_position, false)
      |> then(fn {_, {nx, ny}} -> get_element(map, {nx, ny}) end)

    rotate = next_cell in ["#", "O"]

    {new_direction, next_position} = get_next_guard_position(direction, guard_position, rotate)
    next_cell = get_element(map, next_position)
    cond do
      step > 80_000 ->
        IEx.pry()
        {true, tentative_block_position}
      next_cell == "4" -> {true, tentative_block_position}
      next_cell == "3" ->
        map
        |> set_element(next_position, "4")
        |> check_loop(next_position, new_direction, tentative_block_position, step + 1)
      next_cell == "2" ->
        map
        |> set_element(next_position, "3")
        |> check_loop(next_position, new_direction, tentative_block_position, step + 1)
      next_cell == "1" ->
        map
        |> set_element(next_position, "2")
        |> check_loop(next_position, new_direction, tentative_block_position, step + 1)
      true ->
        map
        |> set_element(next_position, "1")
        |> check_loop(next_position, new_direction, tentative_block_position, step + 1)
    end
  end

  defp set_element(map, {x, y}, value), do: List.update_at(map, x, fn row -> List.replace_at(row, y, value) end)

  defp find_guard_position(map) do
    map
    |> Enum.with_index()
    |> Enum.find(fn {x, _} -> Enum.member?(x, "^") or Enum.member?(x, "v") or Enum.member?(x, "<") or Enum.member?(x, ">") end)
    |> then(fn {x, i} -> {i, Enum.find_index(x, fn y -> y == "^" or y == "v" or y == "<" or y == ">" end)} end)
  end

  defp get_element(map, {x, y} = _position, "^"), do: get_element(map, {x - 1, y})
  defp get_element(map, {x, y} = _position, "v"), do: get_element(map, {x + 1, y})
  defp get_element(map, {x, y} = _position, "<"), do: get_element(map, {x, y - 1})
  defp get_element(map, {x, y} = _position, ">"), do: get_element(map, {x, y + 1})
  defp get_element(map, {x, y} = _position), do: map |> Enum.at(x) |> Enum.at(y)

  defp get_next_guard_position("^", {x, y}, true = _rotate), do: {">", {x, y + 1}}
  defp get_next_guard_position("v", {x, y}, true = _rotate), do: {"<", {x, y - 1}}
  defp get_next_guard_position("<", {x, y}, true = _rotate), do: {"^", {x - 1, y}}
  defp get_next_guard_position(">", {x, y}, true = _rotate), do: {"v", {x + 1, y}}

  defp get_next_guard_position("^", {x, y}, false = _rotate), do: {"^", {x - 1, y}}
  defp get_next_guard_position("v", {x, y}, false = _rotate), do: {"v", {x + 1, y}}
  defp get_next_guard_position("<", {x, y}, false = _rotate), do: {"<", {x, y - 1}}
  defp get_next_guard_position(">", {x, y}, false = _rotate), do: {">", {x, y + 1}}

  def get_data do
    File.read!("lib/day_6/input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&(String.split(&1, "", trim: true)))
  end
end
