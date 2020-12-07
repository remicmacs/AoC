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
	defp split_contained_rule(rule) do
		if rule == "no other bags" do
			# IO.puts("No bag")
			{String.to_atom("end"), 0}
		else
			if Regex.match?(~r/.*bags$/, rule) do
				# IO.puts("bagssss")
				num_color = String.slice(rule, 0..-6)
				color = String.slice(num_color, 2..-1)
				count = String.to_integer(String.at(num_color, 0))
				{String.to_atom(color), count}
			else
				# IO.puts("one bag")
				num_color = String.slice(rule, 0..-5)
				color = String.slice(num_color, 2..-1)
				count = String.to_integer(String.at(num_color, 0))
				{String.to_atom(color), count}
			end
		end
	end

	def total_descendant_bags({:end, 0}, _map_ref), do: 0
	def total_descendant_bags({color, bag_count}, map_ref) do
		descendants_bags = map_ref[color]
			|> Enum.map(&(total_descendant_bags(&1, map_ref)))
			|> Enum.sum
		# IO.inspect(color, label: "Computing descendants of ")
		# IO.inspect(map_ref[color], label: "Descendants are")
		# IO.inspect(descendants_bags, label: "descendants bags sums", charlists: :as_lists)

		bag_count+ (bag_count * descendants_bags)
	end

	def parse_rule(rule) do
		[container, contained] = String.split(rule, " contain ")
		# Removing "bags" from container rule string
		container = String.slice(container, 0..-6)
		contained = contained
			|> String.split(", ")
			# Removing trailing dot
			|> Enum.map(&(String.replace(&1, ".", "")))
			|> Enum.map(&split_contained_rule/1)
		{String.to_atom(container), contained}
	end

	def parse_rules(rules) do
		rules
			|> Enum.map(&parse_rule/1)
			|> Map.new
	end

	def rule_match?(map_ref, {container, contained}) do
		# IO.inspect(container, label: "evaluated rule")
		map_without_current = map_ref
			# |> IO.inspect(label: "before removing")
			|> Map.delete(container)
			# |> IO.inspect(label: "remaining rules")
		colors_to_investigate = Enum.map(contained, fn {key, _} -> key end)
		current_level = :"shiny gold" in colors_to_investigate
			# |> IO.inspect
		if map_size(map_ref) == 0 do
			current_level
		else
			{investigate, _} = Map.split(map_ref, colors_to_investigate)
			current_level or investigate
				|> Enum.any?(&(rule_match?(map_without_current, &1)))
		end
	end

	def file_name_load(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
	end

	def process_pt1(file_name) do
		rules = file_name
			|> file_name_load
			|> String.split("\n")
			|> parse_rules
		Enum.count(rules, &(rule_match?(rules, &1)))
	end

	def process_pt2(file_name) do
		rules = file_name
			|> file_name_load
			|> String.split("\n")
			|> parse_rules
			# |> IO.inspect
		total_descendant_bags({:"shiny gold", 1}, rules) - 1
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Helpers.process_pt1/1, &Helpers.process_pt2/1)