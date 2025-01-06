defmodule Utils.Dijkstra do
  alias Utils.PriorityQueue

  def dijkstra(pq, graph, goal, seen \\ %{}) do
    case PriorityQueue.pop(pq) do
      :empty -> nil

      {:ok, {dir, [curr | _] = path}, score, pq} ->
        cond do
          curr == goal -> {path, score}

          seen[{curr, dir}] <= score -> dijkstra(pq, graph, goal, seen)

          true ->
            seen = Map.put(seen, {curr, dir}, score)

            pq =
              graph[curr]
              |> Enum.reduce(
                pq,
                fn neighbor, pq ->
                  s = subtract(neighbor, curr)
                  dir2 = normalize(s)
                  distance = norm(s)

                  case dot(dir, dir2) do
                    1 -> PriorityQueue.push(pq, {dir2, [neighbor | path]}, score + distance)
                    0 -> PriorityQueue.push(pq, {dir2, [neighbor | path]}, score + distance + 1000)
                    -1 -> pq
                  end
                end
              )

            dijkstra(pq, graph, goal, seen)
        end
    end
  end

  def dijkstra_combined_path(pq, graph, goal, min_score, seen \\ %{}, acc \\ MapSet.new()) do
    case PriorityQueue.pop(pq) do
      :empty ->
        acc

      {:ok, {dir, [curr | _] = path}, score, pq} ->
        cond do
          curr == goal and score > min_score ->
            acc

          curr == goal ->
            acc = path |> expand_path() |> MapSet.union(acc)
            dijkstra_combined_path(pq, graph, goal, min_score, seen, acc)

          seen[{curr, dir}] < score ->
            dijkstra_combined_path(pq, graph, goal, min_score, seen, acc)

          true ->
            seen = Map.put(seen, {curr, dir}, score)

            pq =
              for neighbor <- graph[curr], reduce: pq do
                pq ->
                  s = subtract(neighbor, curr)
                  dir2 = normalize(s)
                  distance = norm(s)

                  case dot(dir, dir2) do
                    1 -> PriorityQueue.push(pq, {dir2, [neighbor | path]}, score + distance)
                    0 -> PriorityQueue.push(pq, {dir2, [neighbor | path]}, score + distance + 1000)
                    -1 -> pq
                  end
              end

            dijkstra_combined_path(pq, graph, goal, min_score, seen, acc)
        end
    end
  end

  defp subtract({i1, j1}, {i2, j2}) do
    {i1 - i2, j1 - j2}
  end

  defp norm({i, j}) do
    abs(i) + abs(j)
  end

  defp dot({i1, j1}, {i2, j2}) do
    i1 * i2 + j1 * j2
  end

  defp normalize({i, 0}) do
    {div(i, abs(i)), 0}
  end

  defp normalize({0, j}) do
    {0, div(j, abs(j))}
  end

  defp expand_path(path) do
    path
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.flat_map(fn
      [{i1, j}, {i2, j}] -> Enum.map(i1..i2, &{&1, j})
      [{i, j1}, {i, j2}] -> Enum.map(j1..j2, &{i, &1})
    end)
    |> MapSet.new()
  end
end
