defmodule Helpers do
	def parse(stream) do
		stream
		|> Stream.map(&String.replace(&1, "\n", ""))
	end

	def split_password_and_policy(string) do
		[policy_range, policy_char, pw] = string
			|> String.split(" ")
		policy_char = String.replace(policy_char, ":", "")
		policy_range = policy_range
			|> String.split("-")
			|> Enum.map(&String.to_integer/1)
		%{
			policy:
			%{
				range: policy_range,
				char: policy_char
			},
			pw: pw
		}
	end

	def count_substring(_, ""), do: 0
	def count_substring(str, sub) do
		length(String.split(str, sub)) - 1
	end

	def pw_respects_policy?(%{policy: policy, pw: pw}) do
		%{range: prange, char: pchar} = policy
		count = count_substring(pw, pchar)
		[min, max] = prange
		(count <= max and count >= min)
	end
end

IO.stream(:stdio, :line)
	|> Helpers.parse
	|> Enum.to_list
	|> Enum.map(&Helpers.split_password_and_policy/1)
	# |> IO.inspect
	|> Enum.filter(&Helpers.pw_respects_policy?/1)
	# |> IO.inspect
	|> length
	|> IO.puts