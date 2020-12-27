defmodule Run do
	def check(in_file, out_file, process_fn_pt1, process_fn_pt2) do
		{:ok, expected} = File.read(out_file <> ".1")

		# Maybe factor out parsing fn ? Or is it always integers ?
		expected1 = String.to_integer(expected)

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

	def get_all_coordinates_in_enclosure({min_x, min_y, min_z} = min, {max_x, max_y, max_z} = max) do
		min_x = min_x - 1
		min_y = min_y - 1
		min_z = min_z - 1

		max_x = max_x + 1
		max_y = max_y + 1
		max_z = max_z + 1

		for x <- min_x..max_x, y <- min_y..max_y, z <- min_z..max_z, into: [] do
			{x, y, z}
		end
	end

	def neighbor_coords({x, y, z} = coords) do
		IO.inspect(coords, label: "in coords")
		neighbs = for x_inc <- -1..1, y_inc <- -1..1, z_inc <- -1..1, into: MapSet.new do
			{x + x_inc, y + y_inc, z + z_inc}
		end
		MapSet.delete(neighbs, coords)
			|> Enum.to_list
	end

	def file_name_load(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
	end

	def process_pt1(file_name) do
		file_name
	end

	def process_pt2(file_name) do
		file_name
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Helpers.process_pt1/1, &Helpers.process_pt2/1)

IO.inspect(Enum.count(Helpers.get_all_coordinates_in_enclosure({0,0,0},{2,2,0})))