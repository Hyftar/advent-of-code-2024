defmodule Day17.Solution do
  def solve_question_1 do
    get_initial_state()
    |> run()
    |> then(fn %{ output: output } -> Enum.join(output, ",") end)
  end

  def solve_question_2 do
    nil
  end

  def run() do
    get_initial_state()
    |> run()
  end

  def run(:debug) do
    get_initial_state()
    |> tap(&display_state/1)
    |> tap(fn _ -> IO.gets("Press enter to continue...") end)
    |> run(debug: true)
  end

  def run(state, opts \\ [])
  def run(%{ instruction_pointer: ip, halt: halt, output: output} = state, opts) when ip >= halt do
    state
  end

  def run(%{ instruction_pointer: ip, program: program } = state, opts) do
    program
    |> Enum.slice(ip, 2)
    |> then(fn [opcode, operand] -> compute_instruction(state, opcode, operand) end)
    |> then(
      fn state ->
        if Keyword.get(opts, :debug) do
          state
          |> tap(&display_state/1)
          |> tap(fn _ -> IO.gets("Press enter to continue...") end)
          |> run(opts)
        else
          run(state, opts)
        end
      end)
  end

  def compute_instruction(%{ registers: %{ A: a } } = state, 0, operand) do
    state
    |> operand_value(operand, :combo)
    |> then(&div(a, 2 ** &1))
    |> then(&put_in(state[:registers][:A], &1))
    |> next_instruction
  end

  def compute_instruction(%{ registers: %{ B: b } } = state, 1, operand) do
    state
    |> operand_value(operand, :literal)
    |> then(&Bitwise.bxor(b, &1))
    |> then(&put_in(state[:registers][:B], &1))
    |> next_instruction
  end

  def compute_instruction(state, 2, operand) do
    state
    |> operand_value(operand, :combo)
    |> then(&rem(&1, 8))
    |> then(&put_in(state[:registers][:B], &1))
    |> next_instruction
  end

  def compute_instruction(%{ registers: %{ A: 0 } } = state, 3, _operand), do: next_instruction(state)
  def compute_instruction(%{ registers: %{ A: _ } } = state, 3, operand) do
    state
    |> operand_value(operand, :literal)
    |> then(&next_instruction(state, &1))
  end

  def compute_instruction(%{ registers: %{ B: b, C: c } } = state, 4, _operand) do
    Bitwise.bxor(b, c)
    |> then(&put_in(state[:registers][:B], &1))
    |> next_instruction
  end

  def compute_instruction(state, 5, operand) do
    state
    |> operand_value(operand, :combo)
    |> then(&Kernel.rem(&1, 8))
    |> then(fn result -> Map.update(state, :output, [result], &(&1 ++ [result])) end)
    |> next_instruction
  end

  def compute_instruction(%{ registers: %{ A: a } } = state, 6, operand) do
    state
    |> operand_value(operand, :combo)
    |> then(&div(a, 2 ** &1))
    |> then(&put_in(state[:registers][:B], &1))
    |> next_instruction
  end

  def compute_instruction(%{ registers: %{ A: a } } = state, 7, operand) do
    state
    |> operand_value(operand, :combo)
    |> then(&div(a, 2 ** &1))
    |> then(&put_in(state[:registers][:C], &1))
    |> next_instruction
  end

  def next_instruction(state, instruction), do: put_in(state[:instruction_pointer], instruction)
  def next_instruction(%{ instruction_pointer: ip } = state), do: put_in(state[:instruction_pointer], ip + 2)

  def operand_value(_state, operand, :literal), do: operand

  def operand_value(_state, operand, :combo) when operand in 0..3, do: operand
  def operand_value(%{ registers: %{ A: a } } = _state, 4, :combo), do: a
  def operand_value(%{ registers: %{ B: b } } = _state, 5, :combo), do: b
  def operand_value(%{ registers: %{ C: c } } = _state, 6, :combo), do: c

  def operand_value(_state, 7, :combo), do: throw("Combo operand 7 is reserved and will not appear in valid programs")

  def get_initial_state do
    File.read!("lib/day_17/input.txt")
    |> String.split("\n\n", trim: true)
    |> then(
      fn [register_lines, program_line] ->
        registers =
          register_lines
            |> String.split("\n", trim: true)
            |> Stream.map(
              fn line ->
                Regex.run(~r/Register (?<register>\w+): (?<value>\d+)/, line, capture: [:register, :value])
                |> then(fn [name, value] -> {String.to_atom(name), String.to_integer(value)} end)
              end
            )
            |> Enum.into(Map.new())

        program =
          Regex.run(~r/Program: (?<program>(?:\d+,?)+)/, program_line, capture: [:program])
          |> hd()
          |> String.split(",", trim: true)
          |> Enum.map(&String.to_integer/1)

        %{
          registers: registers,
          program: program,
          instruction_pointer: 0,
          output: [],
          halt: length(program)
        }
      end
    )
  end

  def display_state(%{ registers: %{ A: a, B: b, C: c }, output: output, program: program, instruction_pointer: ip } = state) do
    IEx.Helpers.clear()

    out_a = Integer.to_string(a)
    out_b = Integer.to_string(b)
    out_c = Integer.to_string(c)

    oct_a = Integer.to_string(a, 8)
    oct_b = Integer.to_string(b, 8)
    oct_c = Integer.to_string(c, 8)

    [instruction, operand] = Enum.slice(program, ip, 2)

    operand =
      operand_value(state, operand, if(instruction in [1, 3], do: :literal, else: :combo))


    out_ope = Integer.to_string(operand)
    oct_ope = Integer.to_string(operand, 8)
    IO.puts("+----- registers -----+---- octal ----+")

    IO.puts("| A |#{String.pad_leading(out_a, 17)}|#{String.pad_leading(oct_a, 15)}|")
    IO.puts("| B |#{String.pad_leading(out_b, 17)}|#{String.pad_leading(oct_b, 15)}|")
    IO.puts("| C |#{String.pad_leading(out_c, 17)}|#{String.pad_leading(oct_c, 15)}|")
    IO.puts("|ope|#{String.pad_leading(out_ope, 17)}|#{String.pad_leading(oct_ope, 15)}|")
    IO.puts("+---------------------+---------------+\n")

    IO.puts("+------ program ------+")
    IO.puts("| ix | inst | operand |")
    IO.puts("+----+------+---------+")
    program
    |> Stream.with_index()
    |> Stream.chunk_every(2)
    |> Stream.map(
      fn [{instruction, i}, {operand, j}] ->
        [{opcode_to_name(instruction), i}, {Integer.to_string(operand), j}]
      end)
    |> Stream.map(
      fn [{instruction, i}, {operand, _}] ->
        cond do
          ip == i ->
            "| #{i |> Integer.to_string() |> String.pad_leading(2)} |"
            <> IO.ANSI.green_background()
            <> String.pad_leading(instruction, 6)
            <> IO.ANSI.reset()
            <> "|"
            <> IO.ANSI.cyan_background()
            <> String.pad_leading(operand, 9)
            <> IO.ANSI.reset()
            <> "|"

          true ->
            "| #{i |> Integer.to_string() |> String.pad_leading(2)} |#{String.pad_leading(instruction, 6)}|#{String.pad_leading(operand, 9)}|"
        end
      end)
    |> Enum.join("\n")
    |> IO.puts()

    IO.puts("+---------------------+\n")

    IO.puts("+---------------------------- output ----------------------------+")
    output
    |> Enum.map(&Integer.to_string/1)
    |> then(fn output -> "|#{output |> Enum.join(" ") |>String.pad_leading(64)}|" end)
    |> IO.puts()
    IO.puts("+----------------------------------------------------------------+\n")
  end

  def opcode_to_name(0), do: "adv"
  def opcode_to_name(1), do: "bxl"
  def opcode_to_name(2), do: "bst"
  def opcode_to_name(3), do: "jnz"
  def opcode_to_name(4), do: "bxc"
  def opcode_to_name(5), do: "out"
  def opcode_to_name(6), do: "bdv"
  def opcode_to_name(7), do: "cdv"
end
