defmodule AdventOfCode2024 do
  use Application

  @impl true
  def start(_type, _args) do
    solve_many(System.argv())
    {:ok, self()}
  end

  def solve_many([]) do
    IO.puts("Please provide a day number")
    {:error, "No day number supplied"}
  end

  def solve_many(args) do
    args
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&(Task.async(fn -> solve(&1) end)))
    |> Task.await_many(:infinity)
    |> Enum.each(
      fn {{part_1_result, part_1_time}, {part_2_result, part_2_time}} ->
        IO.puts("Part #1 : #{part_1_result} in #{part_1_time}")
        IO.puts("Part #2 : #{part_2_result} in #{part_2_time}")
      end)
  end

  def solve(day, opts \\ []) do
    if Keyword.get(opts, :benchmark) do
      Benchee.run(
        %{
          "Part 1" => fn -> apply(:"Elixir.Day#{day}.Solution", :solve_question_1, []) end,
          "Part 2" => fn -> apply(:"Elixir.Day#{day}.Solution", :solve_question_2, []) end
        }
      )
    else
      {
        run_with_timer(:"Elixir.Day#{day}.Solution", :solve_question_1, []),
        run_with_timer(:"Elixir.Day#{day}.Solution", :solve_question_2, [])
      }
    end
  end

  def run_with_timer(module, function, args) do
    :timer.tc(module, function, args)
    |> then(fn {time, result} -> {result, "#{time / 1000}ms"} end)
  end
end
