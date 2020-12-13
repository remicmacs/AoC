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

	def split(file_contents) do
		[timestamp, bus_lines] = String.split(file_contents, "\n")

		timestamp = String.to_integer(timestamp)
		bus_lines = bus_lines
			|> String.split(",")
			|> Enum.filter(fn x -> x != "x" end)
			|> Enum.map(&String.to_integer/1)
		{timestamp, bus_lines}
	end

	def find_next({timestamp, bus_lines}) do
		next = Enum.map(bus_lines, fn x -> rem(timestamp, x) end)
		zipped = Enum.zip(bus_lines, next)
		zipped = Enum.map(zipped, fn {bus_line, elapsed} -> {bus_line, bus_line - elapsed} end)
		Enum.min_by(zipped, fn {bus_line, wait} -> wait end)
	end

	def process_pt1(file_name) do
		{bus_line, wait} = file_name
			|> file_name_load
			|> split
			|> find_next
		bus_line * wait
	end

	def process_pt2(file_name) do
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Helpers.process_pt1/1, &Helpers.process_pt2/1)