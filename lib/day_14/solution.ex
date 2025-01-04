defmodule Day14.Solution do
  @map_width 101
  @map_height 103

  def solve_question_1 do
    get_data()
    |> simulate(100, @map_width, @map_height)
    |> safety_factors(@map_width, @map_height)
    |> Enum.reduce(1, &(&1 * &2))
  end

  def solve_question_2 do
    # Solution for part 2 is simply searching the output file and finding patterns
    get_data()
    |> simulate(10_000, @map_width, @map_height, 0, print: true) # Warning! this will take a while
  end

  def simulate(robots, total_steps, map_width, map_height, current_step \\ 0, opts \\ [])

  def simulate(robots, total_steps, _, _, current_step, _opts) when current_step == total_steps, do: robots
  def simulate(robots, total_steps, map_width, map_height, current_step, opts) do
    robots
    |> Enum.map(fn robot -> move_robot(robot, map_width, map_height) end)
    |> tap(fn robots -> if Keyword.get(opts, :print), do: print_map(robots, current_step + 1, map_width, map_height) end)
    |> simulate(total_steps, map_width, map_height, current_step + 1, opts)
  end

  def move_robot(%{ current_position: {x, y}, velocity: {vx, vy} } = robot, map_width, map_height) do
    Map.merge(
      robot,
      %{
        current_position:
          {
            rem(rem(x + vx, map_height) + map_height, map_height),
            rem(rem(y + vy, map_width) + map_width, map_width)
          }
      }
    )
  end

  def safety_factors(robots, map_width, map_height) do
    [
      {{0, div(map_height, 2) - 1}, {0, div(map_width, 2) - 1}},
      {{0, div(map_height, 2) - 1}, {div(map_width, 2) + 1, map_width}},
      {{div(map_height, 2) + 1, map_height}, {0, div(map_width, 2) - 1}},
      {{div(map_height, 2) + 1, map_height}, {div(map_width, 2) + 1, map_width}}
    ]
    |> IO.inspect
    |> Enum.map(
      fn {from, {x2, y2}} ->
        Enum.count(robots, &(is_in_bounds(&1, from, {x2, y2})))
      end
    )
  end

  def is_in_bounds(%{ current_position: {x, y} }, {x1, x2}, {y1, y2}) do
    x >= x1 and x <= x2 and y >= y1 and y <= y2
  end


  def get_data do
    File.read!("lib/day_14/input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(
      fn line ->
        Regex.scan(~r/-?\d+/, line)
        |> Enum.map(&hd/1)
        |> Enum.map(&String.to_integer/1)
      end
    )
    |> Enum.map(
      fn [x, y, vx, vy] ->
        %{
          initial_position: {y, x},
          velocity: {vy, vx},
          current_position: {y, x}
        }
      end
    )
  end

  def print_map(robots, step, map_width, map_height) do
    [
      "\n                  -- Step ##{step} --"
      |
      0..(map_height - 1)
      |> Enum.map(
        fn y ->
          0..(map_width - 1)
          |> Enum.map(
            fn x ->
              if Enum.any?(robots, fn robot -> robot.current_position == {y, x} end) do
                "#"
              else
                "."
              end
            end
          )
          |> Enum.join("")

          # |> IO.puts
        end
      )
    ]
    |> Enum.join("\n")
    |> tap(&(File.write("lib/day_14/output.txt", &1, [:append])))

    robots
  end
end
