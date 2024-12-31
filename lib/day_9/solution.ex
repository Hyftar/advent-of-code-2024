defmodule Day9.Solution do
  def solve_question_1 do
    %{ files: files, free_space: free_space } =
      get_data()
      |> parse_disk_map()

    compact_disk([], files, free_space, true)
    |> calculate_checksum()
  end

  def solve_question_2 do
    nil
  end

  def get_data do
    File.read!("lib/day_9/input.test.txt")
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def parse_disk_map(data) do
    data
    |> Enum.chunk_every(2, 2, [nil])
    |> Enum.with_index()
    |> Enum.reduce(
      %{files: [], free_space: []},
      fn {[file, free_space], index}, acc ->
        acc
        |> Map.update(:files, [], fn files -> files ++ [%{id: index, length: file}] end)
        |> Map.update(
          :free_space,
          [],
          &(if free_space, do: &1 ++ [%{id: index, length: free_space}], else: &1)
        )
      end
    )
  end

  def compact_disk(compacted_disk, [], _free_space, _tick), do: compacted_disk
  def compact_disk(compacted_disk, [head_file | tail_files], free_space, true = _tick) do
    compact_disk(
      compacted_disk ++ [head_file],
      tail_files,
      free_space,
      false
    )
  end

  def compact_disk(compacted_disk, files, [head_free_space | tail_free_space], false = _tick) do
    last_file = List.last(files)

    cond do
      last_file.length == head_free_space.length ->
        compact_disk(
          compacted_disk ++ [last_file],
          files -- [last_file],
          tail_free_space ++ [head_free_space],
          true
        )

      last_file.length < head_free_space.length ->
        compact_disk(
          compacted_disk ++ [last_file],
          files -- [last_file],
          [%{id: head_free_space.id, length: head_free_space.length - last_file.length} | tail_free_space],
          false
        )

      last_file.length > head_free_space.length ->
        compact_disk(
          compacted_disk ++ [%{id: last_file.id, length: head_free_space.length}],
          (files -- [last_file]) ++ [%{id: last_file.id, length: last_file.length - head_free_space.length}],
          tail_free_space ++ [head_free_space],
          true
        )
    end
  end

  def calculate_checksum(disk) do
    disk
    |> Enum.reduce(
      [],
      fn %{id: id, length: length}, acc ->
        acc ++ List.duplicate(id, length)
      end)
    |> Enum.with_index()
    |> Enum.reduce(
      0,
      fn {id, index}, acc ->
        acc + id * index
      end)
  end
end
