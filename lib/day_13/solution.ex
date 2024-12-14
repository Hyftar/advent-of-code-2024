defmodule Day13.Solution do

  @delta 0.001

  def solve_question_1 do
    get_data()
    |> Enum.map(
      fn [a, b, x] ->
        [a, b]
        |> Nx.tensor(type: :f64)
        |> Nx.transpose
        |> Nx.LinAlg.solve(Nx.tensor(x, type: :f64))
        |> Nx.to_list()
      end
    )
    |> Enum.filter(
      fn results ->
        results
        |> Enum.map(fn x -> (x - round(x)) end)
        |> Enum.all?(fn x -> x < @delta and x > -@delta end)
      end
    )
    |> Enum.map(fn [x, y] -> [x * 3, y] |> Enum.map(&round/1) |> Enum.sum end)
    |> Enum.sum()
  end

  def solve_question_2 do
    get_data()
    |> Enum.map(
      fn [a, b, x] ->
        [a, b]
        |> Nx.tensor(type: :f64)
        |> Nx.transpose
        |> Nx.LinAlg.solve(
          Nx.tensor(x, type: :f64)
          |> Nx.add(Nx.tensor([10000000000000, 10000000000000], type: :f64))
        )
        |> Nx.to_list()
      end
    )
    |> Enum.filter(
      fn results ->
        results
        |> Enum.map(fn x -> (x - round(x)) end)
        |> Enum.all?(fn x -> x < @delta and x > -@delta end)
      end
    )
    |> Enum.map(fn [x, y] -> [x * 3, y] |> Enum.map(&round/1) |> Enum.sum end)
    |> Enum.sum()
  end

  def get_data do
    File.read!("lib/day_13/input.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.map(
      fn group ->
        String.split(group, "\n", trim: true)
        |> Enum.map(
          fn line ->
            Regex.scan(~r/\d+/, line)
            |> Enum.map(&hd/1)
            |> Enum.map(&String.to_integer/1)
          end)
      end)
  end
end
