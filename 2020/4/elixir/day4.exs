defmodule Helpers do
	def parse(stream) do
		stream
			|> IO.inspect
	end

	def check(in_file, out_file, process_fn) do
		{:ok, expected} = File.read(out_file <> ".1")

		# Maybe factor out parsing fn ? Or is it always integers ?
		expected1 = String.to_integer(expected)
		# IO.inspect(expected, label: "expected")

		res1 = process_fn.(in_file)

		if res1 == expected1 do
			IO.puts("Part 1: #{res1}")
		else
			IO.puts("Part 1 mismatch: expected #{expected1} got : ")
			IO.inspect(res1)
		end
	end

	def check_entry(entry) do
		expected_keys = MapSet.new([:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid])
		present_keys = MapSet.new(Map.keys(entry))
		MapSet.subset?(expected_keys, present_keys)

	end

	def raw_entry_to_map(str_entry) do
		str_entry
			|> String.split(["\n", " "])
			|> Enum.map(&String.split(&1, ":"))
			|> Map.new(fn [k, v] -> {String.to_atom(k), v} end)
	end

	def process_part1(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
			|> String.split("\n\n")
			|> Enum.map(&raw_entry_to_map/1)
			|> Enum.count(&check_entry/1)
			# |> IO.inspect
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")

# IO.inspect(in_file, label: "in")
# IO.inspect(expected_file, label: "out")

Helpers.check(in_file, expected_file, &Helpers.process_part1/1)