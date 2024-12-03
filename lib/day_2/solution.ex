defmodule Day2.Solution do
  def solve_question_1 do
    get_data()
    |> Enum.map(&verify/1)
    |> Enum.count(&(&1))
  end

  def solve_question_2 do
    get_data()
    |> Enum.map(&(verify(&1, true)))
    |> Enum.count(&(&1))
  end

  defp get_data do
    File.read!("lib/day_2/input.txt")
    |> String.split("\n")
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(fn x -> String.split(x, " ") |> Enum.map(&String.to_integer/1) end)
  end

  defp verify(line, fault_dampener \\ false) do
    (max_diff(line, 3) && all_increasing_or_decreasing(line))
    |> then(
      fn result ->
        cond do
          result -> result
          fault_dampener ->
            line
            |> Enum.with_index()
            |> Enum.any?(
              fn {_, i} ->
                line
                |> List.delete_at(i)
                |> IO.inspect(label: "slice #{i}", charlists: :list)
                |> verify()
              end
            )
          true -> false
        end
      end
    )
  end

  defp max_diff(line, max_diff) do
    line
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.count(
      fn [a, b] ->
        Kernel.abs(b - a)
        |> then(&(&1 < 1 or &1 > max_diff))
      end)
    |> Kernel.==(0)
  end

  defp all_increasing_or_decreasing(line) do
    (
      line
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.all?(
        fn [a, b] ->
          a <= b
        end)
    )
    ||
    (
      line
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.all?(
        fn [a, b] ->
          a >= b
        end)
    )
  end
end
