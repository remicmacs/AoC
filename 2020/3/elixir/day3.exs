defmodule Helpers do
	def parse(stream) do
		stream
			|> Stream.map(&String.replace(&1, "\n", ""))
	end

	def list_to_indexed_map(list) do
		count = Enum.count(list)
		indices = 0..count-1
		Enum.zip(indices, list)
			|> Map.new
	end

	def slope_step(grid, {inc_i, inc_j}, {start_i, start_j}) do
		width = map_size(grid[0])

		end_i = start_i + inc_i
		big_end_j = (start_j + inc_j)
		end_j = rem( big_end_j, width)
		# IO.inspect({end_i, end_j}, label: "{i,j}")

		{{end_i, end_j}, grid[ end_i ][ end_j ]}
	end

	def solve_slopes(grid) do
		[
			{1, 1},
			{1, 3},
			{1, 5},
			{1, 7},
			{2, 1}
		]
			|> Enum.map(&go_through_grid(&1, grid))
			# |> IO.inspect
			|> Enum.reduce(1, fn el, acc -> el * acc end)
	end

	defp go_through_grid({inc_i, _} = param, grid, height, pos, count) do
		{row_index, _ } = pos
		if row_index + inc_i >= height do
			count
		else
			{pos, obstacle} = slope_step(grid, param, pos)
			count = if obstacle == "#", do: count + 1, else: count
			go_through_grid(param, grid, height, pos, count)
		end
	end
	def go_through_grid(param, grid) do
		height = map_size(grid)
		go_through_grid(param, grid, height, {0,0}, 0)
	end

end
grid_in_list = IO.stream(:stdio, :line)
	|> Helpers.parse
	|> Stream.map(&String.split(&1,"", trim: true))
	|> Enum.to_list
	# |> IO.inspect

grid_in_indexed_map = grid_in_list
	|> Enum.map(&Helpers.list_to_indexed_map/1)
	|> Helpers.list_to_indexed_map
	# |> IO.inspect

# IO.inspect(grid_in_indexed_map[0][0], label: "grid[0][0] is")
# IO.inspect(grid_in_indexed_map[0][3], label: "grid[0][3] is")

# IO.inspect(Helpers.step(grid_in_indexed_map, {0, 0}))
# IO.inspect(Helpers.step(grid_in_indexed_map, {1, 3}))

IO.puts(Helpers.go_through_grid({1,3}, grid_in_indexed_map))
IO.puts(Helpers.solve_slopes(grid_in_indexed_map))
