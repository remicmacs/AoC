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
	def file_name_load(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
	end

	def find_chain(joltages) do
		device_input_joltage = Enum.max(joltages) + 3
		outlet_output_joltage = 0
		joltages = [device_input_joltage, outlet_output_joltage | joltages]
		joltages
			|> Enum.sort
	end

	def compute_diffs(chained_adapters) do
		diffs = chained_adapters
			|> Enum.chunk_every(2, 1, :discard)
			# |> IO.inspect
			|> Enum.map(fn [a,b] -> b - a end)
		threes = Enum.count(diffs, fn x -> x == 3 end)
		ones = Enum.count(diffs, fn x -> x == 1 end)
		{ones, threes}
	end

	def process_pt1(file_name) do
		{ones, threes} = file_name
			|> file_name_load
			|> String.split("\n")
			|> Enum.map(&String.to_integer/1)
			|> find_chain
			|> compute_diffs
		ones * threes
	end

	def process_pt2(file_name) do
		file_name
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Helpers.process_pt1/1, &Helpers.process_pt2/1)