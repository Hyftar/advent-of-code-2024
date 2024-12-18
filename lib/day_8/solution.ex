defmodule Day8.Solution do
  def solve_question_1 do
    %{ map: map, width: width, height: height } = get_data()

    map
    |> Map.get(:antennas)
    |> Enum.flat_map(
      fn {_key, values} ->
        every_pair(values)
        |> Enum.flat_map(
          fn {a, b} ->
            diff(a, b)
            |> then(&([add_diff(a, &1), remove_diff(b, &1)]))
          end)
      end)
    |> Enum.uniq()
    |> Enum.count(&is_visible(&1, width, height))
  end

  def solve_question_2 do
    %{ map: map, width: width, height: height } = get_data()

    map
    |> Map.get(:antennas)
    |> Enum.flat_map(
      fn {_key, values} ->
        every_pair(values)
        |> Enum.flat_map(
          fn {a, b} ->
            expand([a, b], diff(a, b), diff(a, b), width, height)
          end)
      end)
    |> Enum.uniq()
    |> Enum.count(&is_visible(&1, width, height))
  end

  def every_pair([]), do: []
  def every_pair([_x]), do: []
  def every_pair([x | tail]), do: Enum.map(tail, fn y -> {x, y} end) ++ every_pair(tail)

  def diff({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}

  def add_diff({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  def remove_diff({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}

  def is_visible({x, y}, width, height) when x < 0 or x >= width or y < 0 or y >= height, do: false
  def is_visible(_pos, _width, _height), do: true

  def expand(_, _, {dx, dy}, width, height) when abs(dx) > width and abs(dy) > height, do: []
  def expand([a, b] = positions, {idx, idy} = initial_diff, {dx, dy} = _current, width, height) do
    [
      remove_diff(a, {dx, dy}),
      add_diff(b, {dx, dy})
      |
      expand(positions, initial_diff, {dx + idx, dy + idy}, width, height)
    ]
  end

  def get_data(env \\ :actual) do
    file = read_file(env)

    map =
      file
      |> Enum.map(&String.graphemes/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, i} -> Enum.with_index(row) |> Enum.map(fn {char, j} -> {{i, j}, char} end) end)
      |> Enum.filter(&(not match?({_, "."}, &1)))
      |> Enum.reduce(
        %{ antennas: %{}, positions: %{} },
        fn {{i, j}, char}, acc ->
          acc
          |> Map.update!(
            :positions,
            fn positions ->
              positions
              |> Map.put({i, j}, char)
            end
          )
          |> Map.update!(
            :antennas,
            fn antennas ->
              antennas
              |> Map.update(char, [{i, j}], &[{i, j} | &1])
            end
          )
        end)

    %{
      map: map,
      width: String.length(Enum.at(file, 0)),
      height: length(file)
    }
  end

  def read_file(env) do
    if env == :test do
      "lib/day_8/input.test.txt"
    else
      "lib/day_8/input.txt"
    end
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end
