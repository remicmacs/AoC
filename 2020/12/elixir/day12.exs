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
	def do_n({{north, east}, facing}, value), do: {{north + value, east}, facing}
	def do_e({{north, east}, facing}, value), do: {{north, east + value}, facing}
	def do_s({{north, east}, facing}, value), do: {{north - value, east}, facing}
	def do_w({{north, east}, facing}, value), do: {{north, east - value}, facing}
	def do_f({{_, _}, "N"} = state, value), do: do_n(state, value)
	def do_f({{_, _}, "E"} = state, value), do: do_e(state, value)
	def do_f({{_, _}, "S"} = state, value), do: do_s(state, value)
	def do_f({{_, _}, "W"} = state, value), do: do_w(state, value)

	def do_r(state, 270), do: do_l(state, 90)
	def do_r({pos, facing}, 90) do
		case facing do
			"N" -> {pos, "E"}
			"E" -> {pos, "S"}
			"S" -> {pos, "W"}
			"W" -> {pos, "N"}
		end
	end
	def do_r({pos, facing}, 180) do
		case facing do
			"N" -> {pos, "S"}
			"E" -> {pos, "W"}
			"S" -> {pos, "N"}
			"W" -> {pos, "E"}
		end
	end

	def do_l(state, 270), do: do_r(state, 90)
	def do_l({pos, facing}, 90) do
		case facing do
			"N" -> {pos, "W"}
			"E" -> {pos, "N"}
			"S" -> {pos, "E"}
			"W" -> {pos, "S"}
		end
	end
	def do_l(state, 180), do: do_r(state, 180)


	def step(state, []), do: state
	def step(state, instructions) do
		# IO.inspect(state, label: "State")
		[{op, value} = _curr_move | other_instructions] = instructions
		# IO.inspect(_curr_move, label: "Applying")
		new_state = case op do
			"N" -> do_n(state, value)
			"E" -> do_e(state, value)
			"S" -> do_s(state, value)
			"W" -> do_w(state, value)
			"R" -> do_r(state, value)
			"L" -> do_l(state, value)
			"F" -> do_f(state, value)
		end
		step(new_state, other_instructions)
	end

	def parse_move(line) do
		op = String.slice(line, 0..0)
		value = String.slice(line, 1..-1)
		{op, String.to_integer(value)}

	end

	def parse_moves(lines) do
		lines
			|> Enum.map(&parse_move/1)
	end

	def file_name_load(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
	end

	def process_pt1(file_name) do
		moves = file_name
			|> file_name_load
			|> String.split("\n")
			|> parse_moves
		{{x, y}, _} = step({{0, 0}, "E"}, moves)
		abs(x) + abs(y)
	end

	def process_pt2(file_name) do
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Helpers.process_pt1/1, &Helpers.process_pt2/1)