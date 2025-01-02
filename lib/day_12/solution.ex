defmodule Day12.Solution do
  def solve_question_1 do
    get_data()
    |> extract_regions()
  end

  def extract_regions(data) do
    (0..length(data) - 1)
    |> Enum.flat_map(fn x -> (0..length(data) - 1) |> Enum.map(fn y -> {x, y} end) end)
    |> Enum.reduce(
      {%{}, %MapSet{}},
      fn {x, y}, {vr, vp} ->
        if not MapSet.member?(vp, {get_at(data, x,y), x, y}) do
          {new_vr, new_vp} = crawl_region(data, get_at(data, x, y), %{}, x, y, vp, length(Map.keys(vr)))
          {Map.merge(vr, new_vr), MapSet.union(vp, new_vp)}
        else
          {vr, vp}
        end
      end
    )
    |> then(fn {vr, _vp} -> vr end)
    |> Enum.reduce(0, fn {_, %{area: a, perimeter: p}}, acc -> acc + a * p end)
  end

  def crawl_region(data, region_character, visited_regions, x, y, visited_positions, region_id) do
    visited_positions = MapSet.put(visited_positions, {region_character, x, y})

    visited_regions
    |> increment_area(region_character, region_id)
    |> then(
      fn vr ->
        [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
        |> Enum.reduce(
          {vr, visited_positions},
          fn {nx, ny}, {vr, vp} ->
            if get_at(data, nx, ny) == region_character do
              maybe_crawl_region(data, region_character, vr, nx, ny, vp, region_id)
            else
              increment_perimeter(vr, region_character, region_id)
              |> then(fn vr -> {vr, vp} end)
            end
          end)
      end)
  end

  def maybe_crawl_region(data, region_character, visited_regions, x, y, visited_positions, region_id) do
    cond do
      MapSet.member?(visited_positions, {region_character, x, y}) -> {visited_regions, visited_positions}
      true -> crawl_region(data, region_character, visited_regions, x, y, visited_positions, region_id)
    end
  end

  def increment_perimeter(visited_regions, region_character, region_id) do
    Map.update(
      visited_regions,
      "#{region_character}#{region_id}",
      %{ area: 0, perimeter: 1},
      fn previous -> Map.update!(previous, :perimeter, &(&1 + 1)) end
    )
  end

  def increment_area(visited_regions, region_character, region_id) do
    Map.update(
      visited_regions,
      "#{region_character}#{region_id}",
      %{ area: 1, perimeter: 0},
      fn previous -> Map.update!(previous, :area, &(&1 + 1)) end
    )
  end

  def get_at(data, x, y) when x < 0 or y < 0 or x >= length(data) or y >= length(hd(data)), do: nil
  def get_at(data, x, y) do
    data
    |> Enum.at(x)
    |> Enum.at(y)
  end

  def solve_question_2 do
    nil
  end

  def get_data do
    File.read!("lib/day_12/input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end
end
