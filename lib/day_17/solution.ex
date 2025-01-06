defmodule Day17.Solution do
  def solve_question_1 do
    get_initial_state()
    |> run()
    |> then(fn %{ output: output } -> Enum.join(output, ",") end)
  end

  def solve_question_2 do
    nil
  end

  def run(%{ instruction_pointer: ip, halt: halt, output: output} = state) when ip >= halt do
    state
  end

  def run(%{ instruction_pointer: ip, program: program } = state) do
    program
    |> Enum.slice(ip, 2)
    |> then(fn [opcode, operand] -> compute_instruction(state, opcode, operand) end)
    |> run()
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
end
