defmodule Day9.Solution do
  import Day9.{File, FreeSpace}

  def solve_question_1 do
    nil
  end

  def solve_question_2 do
    get_data()
    |> parse_disk_map()
    |> then(
      fn disk ->
        List.pop_at(disk, -1)
        compact_disk(disk, disk |> Enum.reverse())
      end)
    |> calculate_checksum()
  end

  def get_data do
    File.read!("lib/day_9/input.txt")
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def parse_disk_map(data) do
    data
    |> Enum.chunk_every(2, 2, [nil])
    |> Enum.with_index()
    |> Enum.reduce(
      [],
      fn {[file, free_space], index}, acc ->
        acc
        |> List.insert_at(0, %Day9.File{id: index, length: file})
        |> then(
          fn disk ->
            if free_space != nil do
              List.insert_at(disk, 0, %Day9.FreeSpace{length: free_space})
            else
              disk
            end
          end
        )
      end
    )
  end
  def compact_disk([], compacted_disk), do: compacted_disk
  def compact_disk([%Day9.File{} = file | disk], compacted_disk) do
    file_index = Enum.find_index(compacted_disk, fn x -> x == file end)
    {first_free_space, first_free_space_index} =
      compacted_disk
      |> Enum.slice(0, file_index)
      |> Enum.with_index()
      |> Enum.find(
        {nil, nil},
        fn {free_space, _} -> match?(%Day9.FreeSpace{}, free_space) && free_space.length >= file.length end
      )

    cond do
      first_free_space == nil ->
        compact_disk(
          disk,
          compacted_disk
        )

      first_free_space.length == file.length ->
        compact_disk(
          disk,
          compacted_disk
          |> List.replace_at(file_index, %Day9.FreeSpace{length: file.length})
          |> List.replace_at(first_free_space_index, file)
        )

      first_free_space.length > file.length ->
        compact_disk(
          disk,
          compacted_disk
          |> List.replace_at(file_index, %Day9.FreeSpace{length: file.length})
          |> List.replace_at(first_free_space_index, file)
          |> List.insert_at(first_free_space_index + 1, %Day9.FreeSpace{length: first_free_space.length - file.length})
        )
    end
  end

  def compact_disk([%Day9.FreeSpace{} | disk], compacted_disk) do
    compact_disk(disk, compacted_disk)
  end

  def calculate_checksum(disk) do
    disk
    |> Enum.reduce(
      [],
      fn file, acc ->
        if match?(%Day9.FreeSpace{}, file) do
          acc ++ List.duplicate(".", file.length)
        else
          acc ++ List.duplicate(file.id, file.length)
        end
      end)
    |> Enum.with_index()
    |> Enum.reduce(
      0,
      fn {id, index}, acc ->
        if id == "." do
          acc
        else
          acc + id * index
        end
      end)
  end
end
