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
	def split_groups(str) do
		String.split(str, "\n\n")
	end

	def find_all_group_answers(group) do
		group
			|> String.split("", trim: true)
			|> Enum.filter(fn x -> x != "\n" end)
			|> MapSet.new
			|> MapSet.size
	end

	def find_all_common_group_answers(group) do
		ref = ?a..?z |> Enum.to_list |> List.to_string |> String.split("", trim: true)
		group
			|> String.split("\n", trim: true)
			|> Enum.map(&person_string_to_set/1)
			|> Enum.reduce(ref, fn x, acc -> MapSet.intersection(x, MapSet.new(acc)) end)
			# |> IO.inspect
			|> MapSet.size
	end

	def person_string_to_set(pstr) do
		pstr
			|> String.split("", trim: true)
			|> MapSet.new
	end

	def file_name_load(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
	end


	def process_pt1(file_name) do
		file_name
			|> file_name_load
			|> split_groups
			|> Enum.map(&find_all_group_answers/1)
			|> Enum.sum
	end

	def process_pt2(file_name) do
		file_name
			|> file_name_load
			|> split_groups
			|> Enum.map(&find_all_common_group_answers/1)
			|> Enum.sum
	end
end
[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Helpers.process_pt1/1, &Helpers.process_pt2/1)