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

	defp parse_lines(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
			|> String.split("\n")
	end


	def process_pt1(file_name) do
		file_name
			|> parse_lines
			|> Helpers.passes_to_seat_ids
			|> Enum.max
	end

	def process_pt2(file_name) do
		seat_ids = file_name
			|> parse_lines
			|> Helpers.passes_to_seat_ids
		map_seat_ids = seat_ids
			|> MapSet.new
		min_seat_id = seat_ids
			|> Enum.min
		max_seat_id = seat_ids
			|> Enum.max
		# IO.inspect(min_seat_id..max_seat_id)
		map_expected_seat_ids = MapSet.new(min_seat_id..max_seat_id)

		[res | _] = MapSet.difference(map_expected_seat_ids, map_seat_ids)
			# |> IO.inspect
			|> MapSet.to_list
		res

	end
end

defmodule Helpers do
	def compute_seat_id(%{row: row, col: col}), do: (row * 8) + col

	def build_row_col_map(str) do
		%{row: convert_row(str), col: convert_col(str)}
	end

	defp str_f_b_to_bin("F"), do: 0
	defp str_f_b_to_bin("B"), do: 1
	def convert_row(pass) do
		{row_code, ""} = pass
			|> String.slice(0..6)
			|> String.split("", trim: true)
			|> Enum.map(&str_f_b_to_bin/1)
			|> Enum.join
			|> Integer.parse(2)
		row_code
	end

	defp str_l_r_to_bin("L"), do: 0
	defp str_l_r_to_bin("R"), do: 1
	def convert_col(pass) do
		{col_code, ""} = pass
			|> String.slice(-3..-1)
			# |> IO.inspect
			|> String.split("", trim: true)
			|> Enum.map(&str_l_r_to_bin/1)
			|> Enum.join
			# |> IO.inspect
			|> Integer.parse(2)
		col_code
	end

	def passes_to_seat_ids(passes) do
	compute_fn = &(Helpers.compute_seat_id(Helpers.build_row_col_map(&1)))
		passes
			|> Enum.map(compute_fn)
	end


	defmodule Test do

		defp build_in_out(inputs, expecteds) do
			zipped = Enum.zip(inputs, expecteds)
			for {inp, outp} <- zipped, do: %{input: inp, expected: outp}
		end
		defp compare_expected(test_fn, %{input: input, expected: expected}) do
			output = test_fn.(input)
			if output ==  expected do
				{:ok, output}
			else
				{:error, %{expected: expected, output: output}}
			end
		end
		defp filter_results({:error, _}), do: true
		defp filter_results(_), do: false
		defp compare_expecteds(test_fn, test_fn_name, in_out) do
			IO.puts("-> Testing #{test_fn_name}")
			compare_expected_fn = &(compare_expected(test_fn, &1))
			results = in_out |> Enum.map(compare_expected_fn)
				# |> IO.inspect
			errors = results
				|> Enum.filter(&filter_results/1)
				# |> IO.inspect
			error_count = length(errors)

			if (error_count != 0) do
				IO.puts("-> !! #{error_count} found during test of #{test_fn_name}")
				for {_err, %{expected: exp, output: outp}} <- errors do
					IO.puts("\tExpected: \"#{exp}\", got: \"#{outp}\"")
				end
				false
			else
				IO.puts("-> #{test_fn_name} passed successfully")
				true
			end
		end
		def test_compute_seat_id do
			inputs = [
				%{row: 44, col: 5},
				%{row: 70, col: 7},
				%{row: 14, col: 7},
				%{row: 102, col: 4}
			]
			expecteds = [357, 567, 119, 820]
			tested_fn = &Helpers.compute_seat_id/1
			compare_expecteds_fn = &(compare_expecteds(tested_fn, "compute_seat_id", &1))
			compare_expecteds_fn.(build_in_out(inputs, expecteds))
		end

		def test_convert_row do
			inputs = [
				"FBFBBFFRLR",
				"BFFFBBFRRR",
				"FFFBBBFRRR",
				"BBFFBBFRLL"
			]
			expecteds = [44, 70, 14, 102]
			tested_fn = &Helpers.convert_row/1
			compare_expecteds_fn = &(compare_expecteds(tested_fn, "convert_row", &1))
			compare_expecteds_fn.(build_in_out(inputs, expecteds))
		end

		def test_convert_col do
			inputs = [
				"FBFBBFFRLR",
				"BFFFBBFRRR",
				"FFFBBBFRRR",
				"BBFFBBFRLL"
			]
			expecteds = [5, 7, 7, 4]
			tested_fn = &Helpers.convert_col/1
			compare_expecteds_fn = &(compare_expecteds(tested_fn, "convert_col", &1))
			compare_expecteds_fn.(build_in_out(inputs, expecteds))
		end

		def test_all do
			testers = [&test_compute_seat_id/0, &test_convert_row/0, &test_convert_col/0]
			if not Enum.all?(testers, &(&1.())) do
				IO.puts("Tests failed")
			else
				IO.puts("All tests passed")
			end
		end
	end
end

# Helpers.Test.test_all()
[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Run.process_pt1/1, &Run.process_pt2/1)