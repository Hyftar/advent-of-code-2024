defmodule Day12.Solution do
  def solve_question_1 do
    get_data()
    |> crawl_regions()
    |> then(fn {vr, _vp} -> vr end)
    |> Enum.reduce(0, fn {_, %{area: a, perimeter: p}}, acc -> acc + a * p end)
  end

  def solve_question_2 do
    get_data()
    |> crawl_regions()
    |> then(fn {vr, _vp} -> vr end)
    |> Enum.reduce(0, fn {_, %{area: a, corners: c}}, acc -> acc + a * length(c) end)
  end

  def crawl_regions(data) do
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
  end

  def crawl_region(data, region_character, visited_regions, x, y, visited_positions, region_id) do
    visited_positions = MapSet.put(visited_positions, {region_character, x, y})

    # Initialize region tracking if needed
    visited_regions =
      if Map.has_key?(visited_regions, "#{region_character}#{region_id}") do
        visited_regions
      else
        Map.put(visited_regions, "#{region_character}#{region_id}", %{ area: 0, perimeter: 0, corners: [] })
      end

    # Check for corners
    visited_regions = count_corners_around(data, visited_regions, region_character, region_id, x, y)

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
    if not MapSet.member?(visited_positions, {region_character, x, y}) do
      crawl_region(data, region_character, visited_regions, x, y, visited_positions, region_id)
    else
      {visited_regions, visited_positions}
    end
  end

  def increment_perimeter(visited_regions, region_character, region_id) do
    Map.update(
      visited_regions,
      "#{region_character}#{region_id}",
      %{ area: 0, perimeter: 1, corners: [] },
      fn previous -> Map.update!(previous, :perimeter, &(&1 + 1)) end
    )
  end

  def increment_area(visited_regions, region_character, region_id) do
    Map.update(
      visited_regions,
      "#{region_character}#{region_id}",
      %{ area: 1, perimeter: 0, corners: [] },
      fn previous -> Map.update!(previous, :area, &(&1 + 1)) end
    )
  end

  def get_at(data, x, y) when x < 0 or y < 0 or x >= length(data) or y >= length(hd(data)), do: nil
  def get_at(data, x, y) do
    data
    |> Enum.at(x)
    |> Enum.at(y)
  end

  def count_corners_around(data, visited_regions, region_character, region_id, x, y) do
    corner_positions = [
      # X = space of current region
      # O = space of other region (or nil)
      # C = corner
      # {[corners_posititions], [{position_to_check, should_contain_same_region}, ...]}

      # OXO
      # COC
      {[{x + 1, y - 1}, {x + 1, y + 1}], [{{x + 1, y}, false}, {{x, y + 1}, false}, {{x, y - 1}, false}, {{x + 1, y - 1}, false}, {{x + 1, y + 1}, false}]},

      # COC
      # OXO
      {[{x - 1, y - 1}, {x - 1, y + 1}], [{{x - 1, y}, false}, {{x, y + 1}, false}, {{x, y - 1}, false}, {{x - 1, y - 1}, false}, {{x - 1, y + 1}, false}]},

      # OC
      # XO
      # OC
      {[{x - 1, y + 1}, {x + 1, y + 1}], [{{x + 1, y}, false}, {{x - 1, y}, false}, {{x, y + 1}, false}, {{x - 1, y + 1}, false}, {{x + 1, y + 1}, false}]},

      # CO
      # OX
      # CO
      {[{x - 1, y - 1}, {x + 1, y - 1}], [{{x + 1, y}, false}, {{x - 1, y}, false}, {{x, y - 1}, false}, {{x - 1, y - 1}, false}, {{x + 1, y - 1}, false}]},

      # XX
      # CX
      {[{x + 1, y - 1}], [{{x, y - 1}, true}, {{x + 1, y}, true}, {{x + 1, y - 1}, false}]},

      # CX
      # XX
      {[{x - 1, y - 1}], [{{x, y - 1}, true}, {{x - 1, y}, true}, {{x - 1, y - 1}, false}]},

      # XC
      # XX
      {[{x - 1, y + 1}], [{{x, y + 1}, true}, {{x - 1, y}, true}, {{x - 1, y + 1}, false}]},

      # XX
      # XC
      {[{x + 1, y + 1}], [{{x, y + 1}, true}, {{x + 1, y}, true}, {{x + 1, y + 1}, false}]},

      # OX
      # CO
      {[{x + 1, y - 1}], [{{x, y - 1}, false}, {{x + 1, y}, false}]},

      # CO
      # OX
      {[{x - 1, y - 1}], [{{x, y - 1}, false}, {{x - 1, y}, false}]},

      # OC
      # XO
      {[{x - 1, y + 1}], [{{x, y + 1}, false}, {{x - 1, y}, false}]},

      # XO
      # OC
      {[{x + 1, y + 1}], [{{x, y + 1}, false}, {{x + 1, y}, false}]}
    ]

    corners =
      corner_positions
      |> Enum.filter(
        fn {_, positions} ->
          Enum.all?(
            positions,
            fn {{x, y}, is_same_region} ->
              target_char = get_at(data, x, y)

              if is_same_region do
                target_char == region_character
              else
                target_char != region_character
              end
            end)
        end)
      |> Enum.flat_map(fn {positions, _} -> positions end)
      |> Enum.uniq()

    if Enum.any?(corners) do
      Map.update(
        visited_regions,
        "#{region_character}#{region_id}",
        %{ area: 0, perimeter: 0, corners: 1 },
        fn previous -> Map.update!(previous, :corners, &(&1 ++ corners)) end
      )
    else
      visited_regions
    end
  end

  def get_data do
    File.read!("lib/day_12/input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end
end
