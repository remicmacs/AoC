defmodule Helpers do
	def parse(stream) do
		stream
			|> IO.inspect
	end

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

	def check_entry({:cid, _}), do: true
	def check_entry({:ecl, val}), do: check_ecl(val)
	def check_entry({:hcl, val}), do: check_hcl(val)
	def check_entry({:byr, val}), do: check_byr(val)
	def check_entry({:eyr, val}), do: check_eyr(val)
	def check_entry({:iyr, val}), do: check_iyr(val)
	def check_entry({:hgt, val}), do: check_hgt(val)
	def check_entry({:pid, val}), do: check_pid(val)

	defp check_yr_format(val) do
		Regex.match?(~r/^[0-9]{4}$/, val)
	end

	defp check_yr_bound(val, lowbound, hibound) do
		yr = String.to_integer(val)
		(yr >= lowbound) and (yr <=hibound)
	end

	defp check_eyr(val) do
		check_yr_format(val) and check_yr_bound(val, 2020, 2030)
	end

	defp check_iyr(val) do
		check_yr_format(val) and check_yr_bound(val, 2010, 2020)
	end

	defp check_byr(val) do
		check_yr_format(val) and check_yr_bound(val, 1920, 2002)
	end

	defp check_ecl(val) do
		# val |> IO.inspect
		val in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
		# |> IO.inspect
	end

	defp check_hcl(val) do
		Regex.match?(~r/^#[0-9a-f]{6}$/, val)
	end

	defp check_hgt_p("cm", val) do
		(val >= 150) and (val <= 193)
	end

	defp check_hgt_p("in", val) do
		(val >= 59) and (val <= 76)
	end
	defp check_hgt_p(val) do
		# IO.inspect(val)
		unit = String.slice(val, -2..-1)
		value = String.slice(val, 0..-3)
		Regex.match?(~r/^[0-9].*$/, val) and check_hgt_p(unit, String.to_integer(value))
		# |> IO.inspect
	end

	defp check_hgt(val) do
		# IO.inspect(val)
		Regex.match?(~r/^[0-9].*(in|cm)$/, val) and check_hgt_p(val)
		# |> IO.inspect
	end

	defp check_pid(val) do
		# IO.inspect(val)
		Regex.match?(~r/^[0-9]{9}$/, val)
		# |> IO.inspect
	end

	def check_passport(passport) do
		check_passport_keys(passport) and
			passport
				|> Map.to_list
				|> Enum.all?(&check_entry/1)
	end

	def check_passport_keys(passport) do
		expected_keys = MapSet.new([:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid])
		present_keys = MapSet.new(Map.keys(passport))
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
			|> Enum.count(&check_passport_keys/1)
			# |> IO.inspect
	end

	def process_fn_pt2(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
			|> String.split("\n\n")
			|> Enum.map(&raw_entry_to_map/1)
			|> Enum.count(&check_passport/1)
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")

# IO.inspect(in_file, label: "in")
# IO.inspect(expected_file, label: "out")

Helpers.check(in_file, expected_file, &Helpers.process_part1/1, &Helpers.process_fn_pt2/1)