defmodule Helpers do
	def filtered_lines(device) do
		IO.stream(device, :line)
		|> Stream.map(&String.replace(&1, "\n", ""))
		|> Stream.map(&String.to_integer/1)
		|> Enum.to_list
	end

#	def find_match(ref, list), do: find_match(ref, list)
	def find_match(ref, []), do: []
	def find_match(ref, [head | tail])do
		case ref + head do
			2020 -> [ref, head]
			_ -> find_match(ref, tail)
		end
	end

	def find_matches(entries), do: find_matches([], entries)
	defp find_matches(processed, []), do: processed
	defp find_matches(processed, [head | tail]) do
		find_matches([find_match(head, tail) | processed], tail)
	end
end


entries = Helpers.filtered_lines(:stdio)

IO.inspect(entries)
res = Helpers.find_matches(entries)
IO.inspect(res)
res = Enum.filter(res, fn x -> x != [] end)
IO.inspect(res)
[a,b] = hd res
mul = a * b
IO.inspect(mul)