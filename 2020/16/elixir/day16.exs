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
			IO.inspect(res1, charlists: false)
		end

		{:ok, expected} = File.read(out_file <> ".2")

		# Maybe factor out parsing fn ? Or is it always integers ?
		expected2 = String.to_integer(expected)

		res2 = process_fn_pt2.(in_file)

		if res2 == expected2 do
			IO.puts("Part 2: #{res2}")
		else
			IO.puts("Part 2 mismatch: expected #{expected2} got : ")
			IO.inspect(res2, charlists: false)
		end
	end
end

defmodule Helpers do
	def filter_out_matching(candidates, already_matching) do
		Enum.filter(candidates, fn candidate -> not (candidate in already_matching) end )
	end
	def find_matching_fields(fields, found_matches) do
		already_matching = Map.values(found_matches)

		new_fields = fields
			|> Enum.map(
				fn candidates ->
					filter_out_matching(candidates, already_matching) end
			)

		indexed_fields = Enum.with_index(new_fields)

		found_matches = indexed_fields
			|> Enum.filter(fn {candidates, index} -> length(candidates) == 1 end)
			|> Enum.reduce(found_matches, fn {[sole_candidate], index}, acc -> Map.put(acc, index, sole_candidate) end)

		if length(Map.keys(found_matches)) == length(fields) do
			found_matches
		else
			find_matching_fields(new_fields, found_matches)
		end
	end

	def verify_rule?(rule, value) do
		[lower, higher | _nothing] = rule
		value >= lower and value <= higher
	end

	def validate_constraint(constraint, value) do
		{_name, rules} = constraint
		# IO.inspect(rules, charlists: false, label: "rules")
		# IO.inspect(value, label: "value")
		rules
			|> Enum.any?(fn rule -> verify_rule?(rule, value) end)
			# |> IO.inspect(label: "verifies")
	end

	def is_infringing_all_constraints?(value, constraints) do
		# IO.inspect(value, label: "value")
		constraints
			|> Enum.map(fn constraint -> validate_constraint(constraint, value) end)
			# |> IO.inspect
			|> Enum.all?(fn x -> not x end)
	end

	def find_infringing_values(ticket, constraints) do
		ticket
			|> Enum.filter(fn value -> is_infringing_all_constraints?(value, constraints) end)
	end

	def find_scanning_error_rate(input) do
		_tickets = input.nearby_tickets
			|> Enum.map(fn ticket -> find_infringing_values(ticket, input.constraints) end)
			# |> IO.inspect
			|> Enum.concat
			|> Enum.sum
	end

	def values_validate_constraint(zipped_values, constraint) do
		# IO.inspect(constraint, label: "constraint")
		zipped_values
			|> Enum.map(fn value -> validate_constraint(constraint, value) end)
			# |> IO.inspect
			|> Enum.all?(fn value -> value end)
	end

	def find_validating_constraint(zipped_values, constraints) do
		constraints
			|> Enum.filter(fn constraint -> values_validate_constraint(zipped_values, constraint) end)
			|> Enum.map(fn {constraint_name, _rules} -> constraint_name end )
	end

	def zip_nearby_tickets_values(input) do
		input.nearby_tickets
			|> Enum.zip
			|> Enum.map(&Tuple.to_list/1)
	end

	def filter_out_invalid_tickets(input) do
		valid_tickets = input.nearby_tickets
			|> Enum.filter(fn ticket -> [] == find_infringing_values(ticket, input.constraints) end)
		%{input | nearby_tickets: valid_tickets}
	end

	def parse_rule(rule_str) do
		rule_str
			|> String.split("-")
			|> Enum.map(&String.to_integer/1)
	end

	def parse_constraint(constraint_str) do
		[name, rules | _nothing] = constraint_str
			|> String.split(": ")
		rules = rules
			|> String.split(" or ")
			|> Enum.map(&parse_rule/1)
		{name, rules}
	end

	def parse_constraints(constraints) do
		constraints
			|> String.split("\n")
			|> Enum.map(&parse_constraint/1)
			|> Enum.into(%{})
	end

	def parse_ticket_numbers(ticket_nbs) do
		ticket_nbs
			|> String.split(",")
			|> Enum.map(&String.to_integer/1)
	end

	def parse_ticket(ticket) do
		[_header , numbers | _rest ] = ticket
			|> String.split("\n")
		numbers
			|> parse_ticket_numbers
	end

	def parse_nearby_tickets(nearby_tickets) do
		[_header | tickets] = nearby_tickets
			|> String.split("\n")
		tickets
			|> Enum.map(&parse_ticket_numbers/1)
	end

	def parse_input(file_contents) do
		[constraints, ticket, nearby_tickets] = file_contents
			|> String.split("\n\n")
		%{
			constraints: parse_constraints(constraints),
			ticket: parse_ticket(ticket),
			nearby_tickets: parse_nearby_tickets(nearby_tickets)
		}
	end

	def file_name_load(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
	end

	def process_pt1(file_name) do
		file_name
			|> file_name_load
			|> parse_input
			|> find_scanning_error_rate
	end

	def process_pt2(file_name) do
		input = file_name
			|> file_name_load
			|> parse_input
			|> filter_out_invalid_tickets
		zipped_nearby_ticket_values = zip_nearby_tickets_values(input)
		zipped_nearby_ticket_values
			|> Enum.map(
				fn zipped_value -> find_validating_constraint(zipped_value, input.constraints) end
			)
			|> find_matching_fields(%{})
			|> Enum.to_list
			|> Enum.zip(input.ticket)
			|> Enum.filter(fn {{index, key}, ticket_value} -> Regex.match?(~r/^departure.*$/, key) end)
			|> Enum.map(fn {{index, key}, ticket_value} -> ticket_value end)
			|> Enum.reduce(1, fn val, acc -> val * acc end)
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Helpers.process_pt1/1, &Helpers.process_pt2/1)