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

	def step(grid, {start_i, start_j}) do
		width = map_size(grid[0])

		end_i = start_i + 1
		big_end_j = (start_j + 3)
		end_j = rem( big_end_j, width)

		{{end_i, end_j}, grid[ end_i ][ end_j ]}
	end

	defp go_through_grid(grid, height, pos, count) do
		{row_index, _ } = pos
		if row_index == height do
			count
		else
			{pos, obstacle} = step(grid, pos)
			count = if obstacle == "#", do: count + 1, else: count
			go_through_grid(grid, height, pos, count)
		end
	end
	def go_through_grid(grid) do
		height = map_size(grid)
		go_through_grid(grid, height, {0,0}, 0)
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

IO.puts(Helpers.go_through_grid(grid_in_indexed_map))
