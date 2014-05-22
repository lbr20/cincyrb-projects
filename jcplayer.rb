=begin
  class JCPlayer
      implements the necessary public methods needed to launch a game of battleship
=end
class JCPlayer

def initialize()
  @player_name = "JC Bermudez"
  @ship_sizes = [5, 4, 3, 3, 2]
  @ships_locations = []
  @grid_dimensions = [10, 10]
end

def name
  @player_name
end

def new_game
  #-- generate the ship locations by ship's size
  @ship_sizes.all? do |size|

    #-- choose an orientation at random
    orientation = [:across, :down][rand(2)]
    valid_position = false

    while valid_position == false do
      #-- choose a xy position at random
      xy_pos = [rand(10), rand(10)]

      #-- make sure it doesn't go beyond borders and it's not overlapping existing ships
      if orientation == :across && xy_pos[0]+size < @grid_dimensions[0] && !overlap?(xy_pos, size, orientation)
        valid_position = true

      elsif orientation == :down && xy_pos[1]+size < @grid_dimensions[1] && !overlap?(xy_pos, size, orientation)
        valid_position = true
      end
    end    

    @ships_locations << [xy_pos[0], xy_pos[1], size, orientation]
  end

  return @ships_locations
end

def take_turn(state, ships_remaining)
    pos = []

    #-- if no prior hits were made, select a cell at random
    if ! state.any? { |row| row.any? { |cell| cell == :hit } }
      pos = [rand(10), rand(10)]
      #-- validate it's not a prior miss
      while state[pos[1]][pos[0]] == :miss
         pos = [rand(10), rand(10)]
      end
      return pos
    end

    #-- looks for a possible hit adjacent to any of the prior hit cells
    pos = find_possible_hit(ships_remaining, state)

    #-- if nothing was possible, try a random alternative, even if it's a prior miss
    #-- most unlikely, but avoid an :invalid move and losing the game
    if pos == []
      pos = [rand(10), rand(10)]
      while state[pos[1]][pos[0]] == :miss || state[pos[1]][pos[0]] == :hit
        pos = [rand(10), rand(10)]
      end
      return pos
    else
      return pos
    end

end

  private
    #-- returns an array of [x,y]-arrays to conviently
    #-- depict where a ship is located
    def to_coordinates(x, y, size, orientation)
      coords = []

      if orientation == :across
        size.times do |n|
          coords << [x+n, y]  
        end
      elsif orientation == :down
        size.times do |n|
          coords << [x, y+n]
        end
      end

      return coords
    end

    #-- make sure a possible new ship's location will not overlap
    #-- the position of any of the existing ships
    def overlap?(xy_position, size, orientation)
      overlapping = false

      possible_new_ship_coords = to_coordinates(xy_position[0], xy_position[1], size, orientation)

      @ships_locations.map do |ship_location|
        existing_ship_coords = to_coordinates(ship_location[0], ship_location[1], ship_location[2], ship_location[3])

        #-- examine each coordinate of the existing ship versus each
        #-- coordinate of the new possible one
        if existing_ship_coords.any? { |e_coord| possible_new_ship_coords.any? { |n_coord| n_coord == e_coord } }
          overlapping = true
          break
        end
      end

      return overlapping
    end

    def find_possible_hit(ships_remaining, state)
      pos = []
      #-- inspect the state matrix in groups of the size of the ships
      #-- size of ship = max distance a possible hit can be
      ships_remaining.sort.all? do |ship_size|
        #-- loop through the state matrix
        state.each_with_index do |row, row_index|
          row.each_with_index do |col, col_index|
            #-- don't waste time on a previous miss
            if col == :miss
              next
            end
            #-- if this cell was a previous hit, look for possible hits around it
            if col == :hit
              pos = find_possible_cell(state, ship_size, row_index, col_index)
              #-- stop after first positive possibility
              if pos != []
                return pos
              end
            end
          end
        end
      end
      return []
    end

    def find_possible_cell(state, size, row, col)
      pos = []
      #-- look for an adjacent cell where a move could render a valid hit
      #-- go West, then South, then East, finally North
      pos = step_through(state, size, row, col, 1, 0)
      if pos != []
        return pos
      end

      pos = step_through(state, size, row, col, 0, 1)
      if pos != []
        return pos
      end

      pos = step_through(state, size, row, col, -1, 0)
      if pos != []
        return pos
      end

      pos = step_through(state, size, row, col, 0, -1)
      if pos != []
        return pos
      end

      return pos
    end

    def step_through(state, size, row, col, delta_x, delta_y)
      #-- move in a given direction until the ship's size is met
      size.times do |n|
        #-- make sure the new move is not beyond the grid's borders
        if row+(delta_y*n) < 0 || row+(delta_y*n) >= @grid_dimensions[1] ||
           col+(delta_x*n) < 0 || col+(delta_x*n) >= @grid_dimensions[0]
          break
        end
        #-- take only the next :unknown cell, avoid prior hit and miss cells
        if state[row+(delta_y*n)][col+(delta_x*n)] == :unknown
          return [col+(delta_x*n), row+(delta_y*n)]
        end
      end
      #-- not a good move at all
      return []
    end

end
