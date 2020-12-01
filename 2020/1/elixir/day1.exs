defmodule Helpers do
	def filtered_lines(device) do
		IO.stream(device, :line)
		|> Stream.map(&String.replace(&1, "\n", ""))
		|> Stream.map(&String.to_integer/1)
		|> Enum.to_list
	end

	def find_correct_pair([[a,b] | tail]) do
		case a + b do
			2020 -> [a,b]
			_ -> find_correct_pair(tail)
		end
	end

	def find_correct_triple([[a,b,c] | tail]) do
		case a + b + c do
			2020 -> [a,b,c]
			_ -> find_correct_triple(tail)
		end
	end

	def find_all_pairs(entries), do: find_all_pairs([], entries)
	defp find_all_pairs(pairss, []), do: Enum.concat(pairss)
	defp find_all_pairs(pairss, [head | tail]) do
		pairs = for x <- tail, do: [head, x]
		find_all_pairs([pairs | pairss], tail)
	end

	def find_all_triples(entries), do: find_all_triples([], entries)
	defp find_all_triples(tripless, []), do: Enum.concat(tripless)
	defp find_all_triples(tripless, [head | tail]) do
		triples = for [a,b] <- find_all_pairs(tail), do: [a, b, head]
		find_all_triples([triples | tripless], tail)
	end

end


entries = Helpers.filtered_lines(:stdio)

pairs = Helpers.find_all_pairs(entries)
IO.inspect(pairs)
correct_pair = Helpers.find_correct_pair(pairs)
IO.inspect(correct_pair)
[a,b] = correct_pair
IO.inspect(a*b)

triples = Helpers.find_all_triples(entries)
correct_triple = Helpers.find_correct_triple(triples)
IO.inspect(correct_triple)
[a,b,c] = correct_triple
IO.inspect(a*b*c)
