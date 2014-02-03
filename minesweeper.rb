class MinesweeperTile
  attr_reader :bomb, :pos, :game
  attr_accessor :revealed, :flagged

  def initialize(x_index, y_index, game)
    @bomb = false
    @pos = [x_index, y_index]
    @revealed = false
    @game = game
    @flagged = false
  end

  def reveal
    return nil if self.revealed
    return nil if self.flagged
    self.revealed = true
    return true if self.bomb

    edge_bombs = self.adjacent_bombs
    if edge_bombs == 0
      @game.neighbors(@pos).each { |tile| tile.reveal }
    end

    nil
  end

  def adjacent_bombs
    bombs = 0
    neighbors = @game.neighbors(@pos)
    neighbors.each do |neighbor|
      bombs += 1 if neighbor.bomb
    end
    bombs
  end

  def add_bomb
    @bomb = true
  end
end

class MinesweeperGame
  attr_reader :grid
  def initialize(bomb_freq = 0.125, x_dim = 9, y_dim = 9)

    @grid = load || populate_grid(bomb_freq, x_dim, y_dim)
  end


  def load
    puts "Would you like to load a previous game? (y/n)"
    load = gets.chomp
    if load =="y"
      begin
        puts "What is the name of the saved game (not including .txt extension)?"
        saved_game = gets.chomp + ".txt"
        grid = YAML.load(File.read(saved_game))
      rescue
        puts "Invalid name"
        retry
      end
      return grid
    end
    nil
  end

  def save
    begin
      puts "What would you like to name your saved game (not including .txt extension)?"
      filename = gets.chomp + ".txt"
      raise if File.exist?(filename)
      File.open(filename, "w") { |f| f.write(@grid.to_yaml) }
    rescue
      puts "A file by that name already exists.  Overwrite?  (y/n)"
      if gets.chomp == "y"
        File.open(filename, "w") { |f| f.write(@grid.to_yaml) }
      else
        retry
      end
    end
  end

  def play
    display_board

    while true
      command, x_pos, y_pos = get_user_input
      x_pos = x_pos.to_i
      y_pos = y_pos.to_i

      case command
      when "r"
        if grid[x_pos][y_pos].reveal
          puts "Sorry, you blew up"
          break
        end
      when "f"
        grid[x_pos][y_pos].flagged = true
      when "u"
        grid[x_pos][y_pos].flagged = false
      end

      if check_victory
        puts "You win!!!!"
        break
      end

      display_board
    end

    puts "Game Over"
    reveal_board
    display_board
  end

  def reveal_board
    grid.each do |row|
      row.each do |tile|
        tile.reveal
      end
    end
  end

  def check_victory
    num_flags = 0
    num_bombs = 0
    num_unrevealed = 0

    grid.each do |row|
      row.each do |tile|
        num_bombs += 1 if tile.bomb
        num_flags += 1 if tile.flagged
        num_unrevealed +=1 unless tile.revealed
      end
    end

    if num_flags == num_bombs && num_flags == num_unrevealed
      true
    else
      false
    end
  end


  def get_user_input
    valid_input = false
    inputs = ""

    until valid_input
      puts "Please enter the coordinates of the space you wish to affect."
      puts "Possible actions: f = flag, r = reveal, u = unflag"
      puts "(Example:  'f, 0, 1')"

      inputs = gets.chomp.gsub(" ", "").split(",")
      valid_input = valid_input?(inputs)
      if !valid_input
        puts "Error: Input invalid.  Please re-enter."
      end
    end
    inputs
  end

  def valid_input?(inputs)
    if !["f", "r", "u"].include?(inputs[0])
      return false
    elsif !(0..grid.length - 1).include?(inputs[1].to_i)
      return false
    elsif !(0..grid[0].length - 1).include?(inputs[2].to_i)
      return false
    elsif grid[inputs[1].to_i][inputs[2].to_i].revealed
      return false
    elsif inputs[0] == "u" && !grid[inputs[1].to_i][inputs[2].to_i].flagged
      return false
    else
      true
    end
  end

  def populate_grid(bomb_freq, x_dim, y_dim)
    total_bombs = (bomb_freq * x_dim * y_dim).floor

    grid = Array.new(x_dim) { Array.new(y_dim) }
    (0..x_dim - 1).each do |x_index|
      (0..y_dim - 1).each do |y_index|
        grid[x_index][y_index] = MinesweeperTile.new(x_index, y_index, self)
      end
    end

    remaining_bombs = total_bombs
    until remaining_bombs == 0
      pos_tile = grid[rand(x_dim)][rand(y_dim)]
      unless pos_tile.bomb
        pos_tile.add_bomb
        remaining_bombs -= 1
      end
    end
    grid
  end

  def display_board
    display = ""
    num_cols = grid[0].length
    num_cols.times { |index| display << "#{index}|"}
    display << "\n"
    grid.each do |row|
      row.each do |tile|
        if tile.flagged
          display << "F"
        elsif tile.revealed && !tile.bomb
          display << tile.adjacent_bombs.to_s
        elsif tile.revealed && tile.bomb
          display << "*"
        else
          display << "-"
        end
        display << " "
      end
      display << "[#{grid.index(row)}]\n"
    end
    num_cols.times { |index| display << "#{index}|"}
    puts display
  end

  def neighbors(pos)
    neighbors = []
    (pos[0] - 1 .. pos[0] + 1).each do |x_ind|
      (pos[1] - 1 .. pos[1] + 1).each do |y_ind|
        if (0..grid.length - 1).include?(x_ind) && (0..grid[0].length - 1).include?(y_ind)
          neighbors << grid[x_ind][y_ind]
        end
      end
    end
    neighbors
  end
end

if __FILE__ == $PROGRAM_NAME
  game = MinesweeperGame.new
  game.play
end