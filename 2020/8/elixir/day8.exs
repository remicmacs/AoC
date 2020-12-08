defmodule Run do
	def check(in_file, out_file, process_fn_pt1, process_fn_pt2) do
		{:ok, expected} = File.read(out_file <> ".1")

		# Maybe factor out parsing fn ? Or is it always integers ?
		expected1 = String.to_integer(expected)
		# IO.inspect(expected, label: "expected")

		res1 = process_fn_pt1.(in_file)

		if res1 == expected1 do
			IO.puts("Part 1: #{res1}")
		else
			IO.puts("Part 1 mismatch: expected #{expected1} got : ")
			IO.inspect(res1)
		end

		{:ok, expected} = File.read(out_file <> ".2")

		# Maybe factor out parsing fn ? Or is it always integers ?
		expected2 = String.to_integer(expected)
		# IO.inspect(expected, label: "expected")

		res2 = process_fn_pt2.(in_file)

		if res2 == expected2 do
			IO.puts("Part 2: #{res2}")
		else
			IO.puts("Part 2 mismatch: expected #{expected2} got : ")
			IO.inspect(res2)
		end
	end
end

defmodule Helpers do

	defp exec_op({"nop", _}, pos, acc), do: {pos + 1, acc}
	defp exec_op({"acc", value}, pos, acc), do: {pos + 1, acc + value}
	defp exec_op({"jmp", value}, pos, acc), do: {pos + value, acc}

	def exec(program, pos, acc) do
			# |> IO.inspect
		exec_op(program[pos], pos, acc)
	end

	def step(program, %{hist: hist, pos: pos, acc: acc} = _state) do
		if pos > map_size(program) - 1 do
			{:end, acc}
		else
			if pos in hist do
				{:inf, acc}
			else
				{new_pos, new_acc} = exec(program, pos, acc)
				step(program, %{hist: [pos | hist], pos: new_pos, acc: new_acc})
			end
		end
	end

	def try_transform(transform, program) do
		{opcode, val} = program[transform]
		new_op = case opcode do
			"jmp" -> {"nop", val}
			"nop" -> {"jmp", val}
		end

		modified_prog = %{program | transform => new_op}
		step(modified_prog, %{hist: [], pos: 0, acc: 0})

	end
	def try_transforms([head | tail], program) do
		case try_transform(head, program) do
			{:end, acc} -> acc
			{:inf, _acc} -> try_transforms(tail, program)
		end
	end

	def op_parse(op) do
		[opcode, arg | []] = op
		arg = String.to_integer(arg)
		{opcode, arg}
	end

	def parse_program(file_name) do
		file_name
			|> file_name_load
			|> String.split("\n")
			|> Enum.map(&(String.split(&1, " ")))
			|> Enum.map(&op_parse/1)
			|> Enum.with_index
			|> Enum.reduce(%{}, fn {el, index}, acc -> Map.put(acc, index, el) end)
	end

	def find_potentials_transforms(program) do
		program
			|> Enum.filter(fn {_id, {opcode, _val}} -> opcode == "jmp" or opcode == "nop" end)
			|> Enum.map(fn {id, _} -> id end)
	end

	def file_name_load(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
	end

	def process_pt1(file_name) do
		{:inf, res} = file_name
			|> parse_program
			|> step(%{hist: [], pos: 0, acc: 0})
			res
	end

	def process_pt2(file_name) do
		program = file_name
			|> parse_program
		transforms = find_potentials_transforms(program)
		try_transforms(transforms, program)
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Helpers.process_pt1/1, &Helpers.process_pt2/1)