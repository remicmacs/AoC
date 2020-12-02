defmodule Helpers do
	def parse(stream) do
		stream
		|> Stream.map(&String.replace(&1, "\n", ""))
	end

	def split_password_and_policy(string) do
		[policy_indices, policy_char, pw] = string
			|> String.split(" ")
		policy_char = String.replace(policy_char, ":", "")
		policy_indices = policy_indices
			|> String.split("-")
			|> Enum.map(&String.to_integer/1)
		%{
			policy:
			%{
				indices: policy_indices,
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
		%{indices: prange, char: pchar} = policy
		count = count_substring(pw, pchar)
		[min, max] = prange
		(count <= max and count >= min)
	end

	def pw_respects_other_policy?(%{policy: policy, pw: pw}) do
		%{indices: pindices, char: pchar} = policy
		[first, second] =  pindices
			|> Enum.map(&(&1 -1))
			|> Enum.map(&(is_char_at?(pw, pchar, &1)))
			# |> IO.inspect
		(first or second) and not(first and second)
	end

	def is_char_at?(str, char, index) do
		String.at(str, index) == char
	end

end

pws_policies = IO.stream(:stdio, :line)
	|> Helpers.parse
	|> Enum.to_list
	|> Enum.map(&Helpers.split_password_and_policy/1)

pws_policies
	|> Enum.filter(&Helpers.pw_respects_policy?/1)
	# |> IO.inspect
	|> length
	|> IO.puts

pws_policies
	|> Enum.filter(&Helpers.pw_respects_other_policy?/1)
	# |> IO.inspect
	|> length
	|> IO.puts