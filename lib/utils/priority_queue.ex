defmodule Utils.PriorityQueue do
  defstruct tree: nil, map: %{}

  def new do
    %__MODULE__{}
  end

  def push(%__MODULE__{tree: tree, map: map} = heap, value, priority) do
    if map[value] <= priority do
      heap
    else
      tree = meld(tree, {priority, value, []})
      map = Map.put(map, value, priority)
      %__MODULE__{tree: tree, map: map}
    end
  end

  def pop(%__MODULE__{tree: nil}) do
    :empty
  end

  def pop(%__MODULE__{tree: {priority, value, children}, map: map}) do
    tree = pair(children)

    if map[value] == priority do
      map = Map.delete(map, value)
      heap = %__MODULE__{tree: tree, map: map}
      {:ok, value, priority, heap}
    else
      pop(%__MODULE__{tree: tree, map: map})
    end
  end

  defp meld(nil, tree), do: tree
  defp meld(tree, nil), do: tree
  defp meld({p1, v1, c1} = t1, {p2, v2, c2} = t2) do
    if p1 < p2 do
      {p1, v1, [t2 | c1]}
    else
      {p2, v2, [t1 | c2]}
    end
  end

  defp pair([]), do: nil
  defp pair([tree]), do: tree
  defp pair([t1, t2 | rest]) do
    meld(meld(t1, t2), pair(rest))
  end
end
