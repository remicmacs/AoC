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

	# Kudos to Rosettacode.org
	defmodule Chinese do
		# Kudos to Rosettacode.org
		defmodule Modular do
			def extended_gcd(a, b) do
				{last_remainder, last_x} = extended_gcd(round(abs(a)), round(abs(b)), 1, 0, 0, 1)
				{last_remainder, last_x * (if a < 0, do: -1, else: 1)}
			end

			defp extended_gcd(last_remainder, 0, last_x, _, _, _), do: {last_remainder, last_x}
			defp extended_gcd(last_remainder, remainder, last_x, x, last_y, y) do
				quotient   = div(last_remainder, remainder)
				remainder2 = rem(last_remainder, remainder)
				extended_gcd(remainder, remainder2, x, last_x - quotient*x, y, last_y - quotient*y)
			end

			def inverse(e, et) do
				{g, x} = extended_gcd(e, et)
				if g != 1, do: raise "The maths are broken!"
				rem(x+et, et)
			end
		end

		def remainder(mods, remainders) do
			# Find the modulo of the solution
			big_n = Enum.reduce(mods, 1, fn x, acc -> x * acc end)
			# Find yis N/ni
			yis = Enum.map(mods, fn x -> round(big_n / x) end)
			# Find the zis modular inverse of yis
			nis_yis = Enum.zip(mods, yis)
			zis = Enum.map(nis_yis, fn {ni, yi} -> Modular.inverse(yi, ni) end)
			# Solve
			ais_yis_zis = Enum.zip([remainders, yis, zis])
			x = ais_yis_zis
				|> Enum.map(fn {ai, yi, zi} -> ai * yi * zi end)
				|> Enum.sum
			rem(x, big_n)
		end
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

	def split_keep_xs(file_contents) do
		[timestamp, bus_lines] = String.split(file_contents, "\n")

		timestamp = String.to_integer(timestamp)
		bus_lines = bus_lines
			|> String.split(",")
			|> Enum.map(fn x -> if x == "x", do: x, else: String.to_integer(x) end)
		{timestamp, bus_lines}
	end

	def find_next({timestamp, bus_lines}) do
		next = Enum.map(bus_lines, fn x -> rem(timestamp, x) end)
		zipped = Enum.zip(bus_lines, next)
		zipped = Enum.map(zipped, fn {bus_line, elapsed} -> {bus_line, bus_line - elapsed} end)
		Enum.min_by(zipped, fn {_bus_line, wait} -> wait end)
	end

	def find_timestamp(bus_lines) do
		res = Enum.with_index(bus_lines)
		# IO.inspect(res)
		filtered = res
			|> Enum.filter(fn {x, _id} -> x != "x" end)
		# IO.inspect(filtered)
		mods = Enum.map(filtered, fn {x, _id} -> x end)
		rems = Enum.map(filtered, fn {x, id} -> rem(x - id, x) end)
		Chinese.remainder(mods, rems)
	end

	def file_name_load(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
	end

	def process_pt1(file_name) do
		{bus_line, wait} = file_name
			|> file_name_load
			|> split
			|> find_next
		bus_line * wait
	end

	def process_pt2(file_name) do
		{_balek, bus_lines} = file_name
			|> file_name_load
			|> split_keep_xs
		bus_lines
			|> find_timestamp
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Helpers.process_pt1/1, &Helpers.process_pt2/1)