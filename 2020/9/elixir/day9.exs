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
	def find_preamble_pairs(entries), do: find_all_pairs([], entries)
	defp find_all_pairs(pairss, []), do: Enum.concat(pairss)
	defp find_all_pairs(pairss, [head | tail]) do
		pairs = for x <- tail, do: [head, x]
		find_all_pairs([pairs | pairss], tail)
	end

	def find_preamble_sums(preamble) do
		preamble
			|> find_preamble_pairs
			|> Enum.map(fn [x, y | _] -> x + y end)
	end

	def check(numbers, preamble_len) do
		# Never should we hit this case
		if (length(numbers) == preamble_len) do
			nil
		else
			preamble = Enum.slice(numbers, 0..preamble_len-1)
			evaluated = Enum.at(numbers, preamble_len)
			# IO.inspect(preamble, label: "Preamble is", charlists: false)
			sums = preamble
				|> find_preamble_sums
			# IO.inspect(sums, label: "Computed sums", charlists: false)
			if evaluated not in sums do
				evaluated
			else
				next_numbers = Enum.slice(numbers, 1..-1)
				check(next_numbers, preamble_len)
			end

		end
	end


	def file_name_load(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
	end

	def parse_integers_list(file_str) do
		file_str
			|> String.split("\n")
			|> Enum.map(&String.to_integer/1)
	end

	def process_pt1(file_name, preamble_len) do
		file_name
			|> file_name_load
			|> parse_integers_list
			|> check(preamble_len)
	end

	def process_pt2(file_name, preamble_len) do
		file_name
	end
end

[ in_file, preamble_len | _ ] = System.argv

preamble_len = String.to_integer(preamble_len)

expected_file = String.replace(in_file, "in", "out")

pt1 = &(Helpers.process_pt1(&1, preamble_len))
pt2 = &(Helpers.process_pt2(&1, preamble_len))

Run.check(in_file, expected_file, pt1, pt2)