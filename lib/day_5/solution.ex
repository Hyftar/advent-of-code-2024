defmodule Day5.Solution do
  def solve_question_1 do
    [raw_rules, print_queue] =
      File.read!("lib/day_5/input.txt")
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(fn x -> x != "" end)
      |> Enum.chunk_by(&(Regex.match?(~r/^\d+\|\d+/, &1)))

    parsed_rules =
      raw_rules
      |> Enum.map(fn x -> String.split(x, "|") |> Enum.map(&String.to_integer/1) end)
      |> Enum.reduce(
        %{},
        fn [a, b], acc ->
          Map.get_and_update(acc, b, fn current -> {current, assign_default_rule(a, current)} end)
          |> elem(1)
        end)

    print_queue
    |> Enum.map(fn x -> String.split(x, ",") |> Enum.map(&String.to_integer/1) end)
    |> Enum.filter(
      fn line ->
        line
        |> Enum.with_index()
        |> Enum.all?(
          fn {x, i} ->
            rules = Map.get(parsed_rules, x)

            Enum.slice(line, i, length(line) - i)
            |> Enum.all?(fn y -> !Enum.member?(rules, y) end)
          end
        )
      end)
    |> Enum.map(&middle_element/1)
    |> Enum.sum()
  end

  def assign_default_rule(element, nil = _current), do: [element]
  def assign_default_rule(element, current), do: [element] ++ current

  def solve_question_2 do
    [rules, print_queue] =
      File.read!("lib/day_5/input.txt")
      |> String.split("\n\n")

    print_queue =
      print_queue
      |> String.split("\n", trim: true)
      |> Enum.map(fn x -> String.split(x, ",") |> Enum.map(&String.to_integer/1) end)

    print_queue
    |> Enum.map(
      fn line ->
        {
          line,
          Enum.sort_by(
            line,
            &Function.identity/1,
            &(String.contains?(rules, "#{&1}|#{&2}"))
          )
        }
      end)
    |> Enum.filter(fn {line, sorted} -> line != sorted end)
    |> Enum.map(fn {_line, sorted} -> middle_element(sorted) end)
    |> Enum.sum()
  end

  defp middle_element(list) do
    Enum.at(list, div(length(list), 2))
  end
end
