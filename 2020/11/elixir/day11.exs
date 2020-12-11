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
	def print_line(line) do
		line
			|> Enum.map(fn {_id, seat} -> seat end)
			|> Enum.join("")
			|> IO.inspect
	end
	def print_grid(grid) do
		IO.inspect("")
		grid
			|> Enum.map(fn {_id, line} -> line end)
			|> Enum.map(&print_line/1)
		grid
	end
	def file_name_load(file_name) do
		{:ok, file_contents} = File.read(file_name)
		file_contents
	end

	def line_to_row(line_str) do
		String.split(line_str, "", trim: true)
			|> Enum.with_index
			|> Enum.reduce(%{}, fn {el, id}, acc -> Map.put(acc, id, el) end)
			# |> Enum.map(fn {a, b} -> {b , a} end)
			# |> Map.new
	end

	def change_seat_state("L", adj_seats) do
		occupancy = adj_seats
			|> Enum.all?(fn x -> x != "#" end)

		if occupancy do
			"#"
		else
			"L"
		end
	end
	def change_seat_state("#", adj_seats) do
		occupied_seats_count = adj_seats
			|> Enum.count(fn x -> x == "#" end)
		if occupied_seats_count >= 4 do
			"L"
		else
			"#"
		end
	end

	def change_seat_state({x,y} = coordinates, grid) do
		# IO.inspect(coordinates)
		curr_seat = grid[x][y]

		case curr_seat do
			"." -> "."
			state -> change_seat_state(state, find_adjacent_seats(coordinates, grid))
		end
	end

	def change_seat_state2("L", adj_seats) do
		occupancy = adj_seats
			|> Enum.all?(fn x -> x != "#" end)

		if occupancy do
			"#"
		else
			"L"
		end
	end
	def change_seat_state2("#", adj_seats) do
		occupied_seats_count = adj_seats
			|> Enum.count(fn x -> x == "#" end)
		if occupied_seats_count >= 5 do
			"L"
		else
			"#"
		end
	end

	def change_seat_state2({x,y} = coordinates, grid) do
		# IO.inspect(coordinates)
		curr_seat = grid[x][y]

		case curr_seat do
			"." -> "."
			state -> change_seat_state2(state, find_adjacent_seats2(coordinates, grid))
		end
	end

	def step_line(grid, curr_x, max_y) do
		for y <- 0..max_y, into: %{} do
			{y, change_seat_state({curr_x, y}, grid)}
		end
	end

	def step_line2(grid, curr_x, max_y) do
		for y <- 0..max_y, into: %{} do
			{y, change_seat_state2({curr_x, y}, grid)}
		end
	end

	def count_occupied_seats({_, map_line}) do
		Enum.count(map_line, fn {_, seat} -> seat == "#" end)
	end
	def count_occupied(grid) do
		grid
			|> Enum.map(&count_occupied_seats/1)
			|> Enum.sum
	end

	def step_grid(grid, max_x, max_y) do
		new_grid = for x <- 0..max_x, into: %{} do
			{x, step_line(grid, x, max_y)}
		end

		occupied_count = count_occupied(grid)

		{occupied_count, new_grid}
	end

	def step_grid2(grid, max_x, max_y) do
		# print_grid(grid)
		new_grid = for x <- 0..max_x, into: %{} do
			{x, step_line2(grid, x, max_y)}
		end

		occupied_count = count_occupied(grid)

		{occupied_count, new_grid}
	end

	def find_stable_occupied([], grid, max_x, max_y) do
		{occupied_count, new_grid} = step_grid(grid, max_x, max_y)
		find_stable_occupied([occupied_count], new_grid, max_x, max_y)
	end

	def find_stable_occupied(history, grid, max_x, max_y) do
		# IO.inspect(history, charlists: false)
		{occupied_count, new_grid} = step_grid(grid, max_x, max_y)
			# |> IO.inspect(charlists: false)
		[last | _rest ] = history

		if occupied_count == last do
				occupied_count
		else
			find_stable_occupied([occupied_count | history], new_grid, max_x, max_y)
		end
	end

	def find_stable_occupied2([], grid, max_x, max_y) do
		{occupied_count, new_grid} = step_grid(grid, max_x, max_y)
		find_stable_occupied2([occupied_count], new_grid, max_x, max_y)
	end

	def find_stable_occupied2(history, grid, max_x, max_y) do
		# IO.inspect(history, charlists: false)
		{occupied_count, new_grid} = step_grid2(grid, max_x, max_y)
			# |> IO.inspect(charlists: false)
		[last | _rest ] = history

		if occupied_count == last do
				occupied_count
		else
			find_stable_occupied2([occupied_count | history], new_grid, max_x, max_y)
		end
	end

	def find_adjacent_seats({x,y}, grid) do
		[
			grid[x-1][y-1],
			grid[x-1][y],
			grid[x-1][y+1],
			grid[x][y-1],
			grid[x][y+1],
			grid[x+1][y-1],
			grid[x+1][y],
			grid[x+1][y+1]
		]
	end

	def find_up_left({x,y}, grid) do
		case grid[x - 1][y - 1] do
			"." -> find_up_left({x - 1 , y - 1}, grid)
			seat_state -> seat_state
		end
	end
	def find_up({x,y}, grid) do
		case grid[x - 1][y] do
			"." -> find_up({x - 1, y}, grid)
			seat_state -> seat_state
		end
	end
	def find_up_right({x,y}, grid) do
		case grid[x - 1][y + 1] do
			"." -> find_up_right({x - 1 , y + 1}, grid)
			seat_state -> seat_state
		end
	end
	def find_left({x,y}, grid) do
		case grid[x][y - 1] do
			"." -> find_left({x, y - 1}, grid)
			seat_state -> seat_state
		end
	end
	def find_right({x,y}, grid) do
		case grid[x][y + 1] do
			"." -> find_right({x, y + 1}, grid)
			seat_state -> seat_state
		end
	end
	def find_down_left({x,y}, grid) do
		case grid[x + 1][y - 1] do
			"." -> find_down_left({x + 1 , y - 1}, grid)
			seat_state -> seat_state
		end
	end
	def find_down_right({x,y}, grid) do
		case grid[x + 1][y + 1] do
			"." -> find_down_right({x + 1,y + 1}, grid)
			seat_state -> seat_state
		end
	end
	def find_down({x, y}, grid) do
		case grid[x + 1][y] do
			"." -> find_down({x + 1, y}, grid)
			seat_state -> seat_state
		end
	end

	def find_adjacent_seats2({x,y}, grid) do
		[
			find_up_left({x,y}, grid),
			find_up({x,y}, grid),
			find_up_right({x,y}, grid),
			find_left({x,y}, grid),
			find_right({x,y}, grid),
			find_down_left({x,y}, grid),
			find_down({x,y}, grid),
			find_down_right({x,y}, grid)
		]
	end

	def get_grid(file_contents) do
		file_contents
			|> String.split("\n")
			|> Enum.map(&line_to_row/1)
			|> Enum.with_index
			|> Enum.reduce(%{}, fn {el, id}, acc -> Map.put(acc, id, el) end)
	end

	def process_pt1(file_name) do
		grid = file_name
			|> file_name_load
			|> get_grid
		max_x = Enum.max(Map.keys(grid))
		max_y = Enum.max(Map.keys(grid[0]))
		find_stable_occupied([], grid, max_x, max_y)
	end
	def process_pt2(file_name) do
		grid = file_name
			|> file_name_load
			|> get_grid
		max_x = Enum.max(Map.keys(grid))
		max_y = Enum.max(Map.keys(grid[0]))
		find_stable_occupied2([], grid, max_x, max_y)
	end
end

[ in_file | _ ] = System.argv

expected_file = String.replace(in_file, "in", "out")
Run.check(in_file, expected_file, &Helpers.process_pt1/1, &Helpers.process_pt2/1)