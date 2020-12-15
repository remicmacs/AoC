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
	def bit_set2(_v, "X"), do: "X"
	def bit_set2(v, "0"), do: v
	def bit_set2(_v, "1"), do: "1"
	def apply_mask2(mask, value) do
		# IO.inspect(value, label: "value")
		value = Integer.to_string(value, 2)
		# IO.inspect(value, label: "binary value")
		value = String.pad_leading(value, 36, "0")
		# IO.inspect(value, label: "padded value")
		# IO.inspect(mask, label: "mask        ")

		value = String.split(value, "", trim: true)
		mask = String.split(mask, "", trim: true)
		res = Enum.zip(value, mask)
			# |> IO.inspect
			|> Enum.map(fn {v, m} -> bit_set2(v, m) end)
			|> Enum.join("")
		# IO.inspect(res, label: "masked      ")
		# IO.inspect(res, label: "res")
		res
	end
	def bit_set(v, "X"), do: v
	def bit_set(_, m), do: m
	def apply_mask(mask, value) do
		# IO.inspect(value, label: "value")
		value = Integer.to_string(value, 2)
		# IO.inspect(value, label: "binary value")
		value = String.pad_leading(value, 36, "0")
		# IO.inspect(value, label: "padded value")
		# IO.inspect(mask, label: "mask        ")

		value = String.split(value, "")
		mask = String.split(mask, "")
		res = Enum.zip(value, mask)
			# |> IO.inspect
			|> Enum.map(fn {v, m} -> bit_set(v, m) end)
			|> Enum.join("")
		# IO.inspect(res, label: "masked      ")
		res = String.to_integer(res, 2)
		# IO.inspect(res, label: "res")
		res
	end
	def split_register_value(ins) do
		[register, value] = String.split(ins, " = ")
		register = register
			|> String.split(["[", "]"], trim: true)
			|> Enum.filter(fn x -> x != "mem" end)
			|> hd
			|> String.to_integer
		value = String.to_integer(value)
		# IO.inspect(register, label: "register")
		# IO.inspect(value, label: "value")
		{register, value}
	end

	# defp find_all_registers([]), do: []
	defp find_all_registers_p(["X" | []]), do: [["0"], ["1"]]
	defp find_all_registers_p([bit | []]), do: [[bit]]
	defp find_all_registers_p(["X" | tail]) do
		tails = find_all_registers_p(tail)
		zero_tails = tails
			|> Enum.map(fn x -> ["0" | x] end)
			# |> IO.inspect
		one_tails = tails
			|> Enum.map(fn x -> ["1" | x] end)
			# |> IO.inspect
		zero_tails ++ one_tails
	end
	defp find_all_registers_p([bit | tail]) do
		tails = find_all_registers_p(tail)
		tails
			|> Enum.map(fn x -> [bit | x] end)
			# |> IO.inspect
	end

	def find_all_registers(register, mask) do
		# IO.inspect(register, label: "target register", charlists: false)
		# IO.inspect(mask, label: "applied mask", charlists: false)

		masked = apply_mask2(mask, register)
		# IO.inspect(masked, label: "mask applied")
		masked
			|> String.split("", trim: true)
			|> find_all_registers_p
			|> Enum.map(fn x -> Enum.join(x, "") end)
			# |> IO.inspect(label: "result registers")
	end

	def process_new_mask(ins, state) do
		# IO.inspect(ins)
		%{state | mask: String.slice(ins, 7..-1)}
	end

	def process_assignment(ins, state) do
		{register, value} = split_register_value(ins)
		value = apply_mask(state.mask, value)
		registers = Map.put(state.registers, register, value)
		%{state | registers: registers}
	end

	def process_assignment2(ins, state) do
		# IO.inspect(ins, label: "Assignment ins")
		{register, value} = split_register_value(ins)
		registers = find_all_registers(register, state.mask)
			# |> IO.inspect
			|> Enum.map(fn x -> String.to_integer(x, 2) end)
		# IO.inspect(registers, label: "target registers", charlists: false)

		registers = Enum.reduce(registers, state.registers, fn x, acc -> Map.put(acc, x, value) end)
		%{state | registers: registers}
	end

	def process_instruction(ins, state) do
		# IO.inspect(state)
		if Regex.match?(~r/^mask =.*$/, ins) do
			process_new_mask(ins, state)
		else
			process_assignment(ins, state)
		end
	end

	def process_instruction2(ins, state) do
		# IO.inspect(state)
		if Regex.match?(~r/^mask =.*$/, ins) do
			process_new_mask(ins, state)
		else
			process_assignment2(ins, state)
		end
	end

	def step([], state) do
		Enum.sum(Map.values(state.registers))
	end

	def step([curr_instruction | rest_prog], state) do
		new_state = process_instruction(curr_instruction, state)
		step(rest_prog, new_state)
	end

	def step2([], state) do
		Enum.sum(Map.values(state.registers))
	end

	def step2([curr_instruction | rest_prog], state) do
		new_state = process_instruction2(curr_instruction, state)
		step2(rest_prog, new_state)
	end

	def process_program(program) do
		mask = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
		registers = %{}
		state = %{mask: mask, registers: registers}

		step(program, state)
	end

	def process_program2(program) do
		mask = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
		registers = %{}
		state = %{mask: mask, registers: registers}

		step2(program, state)
	end

	def file_name_load(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
	end

	def split_in_lines(file_contents) do
		file_contents
			|> String.split("\n")
	end

	def process_pt1(file_name) do
		file_name
			|> file_name_load
			|> split_in_lines
			|> process_program
	end

	def process_pt2(file_name) do
		file_name
			|> file_name_load
			|> split_in_lines
			|> process_program2
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Helpers.process_pt1/1, &Helpers.process_pt2/1)