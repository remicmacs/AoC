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
	def find_new_nb_p(_ref, _acc, []), do: 0
	def find_new_nb_p(ref, acc, [curr | tail]) do
		if ref == curr do
			acc + 1
		else
			find_new_nb_p(ref, acc + 1, tail)
		end
	end

	def find_new_nb([head | tail]) do
		find_new_nb_p(head, 0, tail)
	end

	def find_new_nb2(%{history: history, existing: existing}) do
		[ref | _tail] = history
		IO.inspect(ref, label: "ref")
		# IO.inspect(tail, label: "history")
		# IO.inspect(existing, label: "existing")
		new_existing = Map.put(existing, ref, 0)
		new_existing = for {k, v} <- new_existing, into: %{}, do: {k, v + 1}
		if ref in Map.keys(existing) do
			value = existing[ref]
			{value, %{history: [value | history], existing: new_existing}}
		else
			{0, %{history: [0 | history], existing: new_existing}}
		end
	end

	def sequence(2020, history), do: find_new_nb(history)
	def sequence(step_nb, history) do
		sequence(step_nb + 1, [find_new_nb(history) | history])
	end


	def sequence1_2(2020, state) do
		{new_nb, _} = find_new_nb2(state)
		new_nb
	end
	def sequence1_2(step_nb, state) do
		{_new_nb, new_state} = find_new_nb2(state)
		sequence1_2(step_nb + 1, new_state)
	end



	def sequence2(30, state) do
		{new_nb, _} = find_new_nb2(state)
		new_nb
	end
	def sequence2(step_nb, state) do
		if rem(step_nb, 10000) == 0 do
			IO.inspect(step_nb, label: "Step")
		end
		{_new_nb, new_state} = find_new_nb2(state)
		sequence2(step_nb + 1, new_state)
	end

	def do_sequence(seed) do
		history = Enum.reverse(seed)
		sequence(length(seed) + 1, history)
	end

	def do_sequence1_2(seed) do
		history = Enum.reverse(seed)
		[_hd | tail] = history

		existing = tail
			|> Enum.with_index
			|> Enum.reduce(%{}, fn {nb, id}, acc -> Map.put(acc, nb, id + 1) end)
		sequence1_2(length(seed) + 1, %{history: history, existing: existing})
	end

	def do_sequence2(seed) do
		history = Enum.reverse(seed)
		[_hd | tail] = history

		existing = tail
			|> Enum.reduce(%{}, fn {nb, id}, acc -> Map.put(acc, nb, id + 1) end)
		sequence2(length(seed) + 1, %{history: history, existing: existing})
	end


	def string_to_ints(file_contents) do
		file_contents
			|> String.split(",", trim: true)
			|> Enum.map(&String.to_integer/1)
	end

	def file_name_load(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
	end

	def process_pt1(file_name) do
		file_name
			|> file_name_load
			|> string_to_ints
			|> do_sequence1_2

	end

	def process_pt2(file_name) do
		file_name
			|> file_name_load
			|> string_to_ints
			|> do_sequence2
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Helpers.process_pt1/1, &Helpers.process_pt2/1)