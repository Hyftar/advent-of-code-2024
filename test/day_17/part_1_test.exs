defmodule Day17.Part1Tests do
  use ExUnit.Case

  import Mock

  defmacro with_file_mock(output, do: expression) do
    quote do
      with_mock(File, [read!: fn _ -> unquote(output) end], do: unquote(expression))
    end
  end

  test "example program is correct" do
    with_file_mock(
      """
        Register A: 729
        Register B: 0
        Register C: 0

        Program: 0,1,5,4,3,0
      """) do
      assert %{ output: [4,6,3,5,6,3,5,2,1,0] } = Day17.Solution.solve_question_1()
    end
  end

  test "example instruction operation 1" do
    with_file_mock(
      """
        Register A: 0
        Register B: 0
        Register C: 9

        Program: 2,6
      """) do
      assert %{ registers: %{ B: 1 }} = Day17.Solution.solve_question_1()
    end
  end

  test "example instruction operation 2" do
    with_file_mock(
      """
        Register A: 10
        Register B: 0
        Register C: 0

        Program: 5,0,5,1,5,4
      """) do
      assert %{ output: [0,1,2] } = Day17.Solution.solve_question_1()
    end
  end

  test "example instruction operation 3" do
    with_file_mock(
      """
        Register A: 2024
        Register B: 0
        Register C: 0

        Program: 0,1,5,4,3,0
      """) do
      assert %{ output: [4,2,5,6,7,7,7,7,3,1,0], registers: %{ A: 0 } } = Day17.Solution.solve_question_1()
    end
  end

  test "example instruction operation 4" do
    with_file_mock(
      """
        Register A: 0
        Register B: 29
        Register C: 0

        Program: 1,7
      """) do
      assert %{ registers: %{ B: 26 } } = Day17.Solution.solve_question_1()
    end
  end

  test "example instruction operation 5" do
    with_file_mock(
      """
        Register A: 0
        Register B: 2024
        Register C: 43690

        Program: 4,0
      """) do
      assert %{ registers: %{ B: 44354 } } = Day17.Solution.solve_question_1()
    end
  end
end
