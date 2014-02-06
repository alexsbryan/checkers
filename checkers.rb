require 'colorize'

class InvalidMoveError < ArgumentError

end

class Piece
  attr_accessor :color, :location, :king
  COLOR_DIRS = {
    :r => 1,
    :b => -1
  }
  def initialize color, location, board, king = false
    @king = king
    @color = color
    @location = location
    @board = board
  end

  def move_diffs(start_pos, end_pos)
    first_coord = end_pos[0] - start_pos[0]
    second_coord = end_pos[1] - start_pos[1]

    [first_coord, second_coord]
  end

  def perform_slide(start_pos, end_pos)
    #take the start_pos and end pos
    #check whether it's valid length for a slide (one diagonal unit)
    #make sure there is no piece in the way

    s_y, s_x = start_pos
    e_y, e_x = end_pos
    m_y, m_x = move_diffs(start_pos, end_pos)

    #maybe make false errors
    #nothing in space to move
    return false if @board.board[s_y][s_x].nil?
    #raise "move too large"
    return false if (m_x).abs > 1 || (m_y).abs > 1
    #raise "space occupied"
    return false if !@board.board[e_y][e_x].nil?
    #checks the move direction times the assigned color direction
    # raise "wrong direction"
    return false if m_y * COLOR_DIRS[@color] <= 0 && !@king

    #make move


    @board.board[e_y][e_x] = self
    @board.board[s_y][s_x] = nil
    self.location = [e_y, e_x]
    maybe_promote

    true

  end

  def perform_jump(start_pos, end_pos)
    #called by the perform_moves method and checks one jump at a time, returns a falsey value or error if the move can't be performed
    s_y, s_x = start_pos
    e_y, e_x = end_pos
    m_y, m_x = move_diffs(start_pos, end_pos)
    unit_y, unit_x = [m_y/m_y.abs,m_x/m_x.abs]

    #nothing in space to move
    return false if @board.board[s_y][s_x].nil?
    #destination occupied
    return false if !@board.board[e_y][e_x].nil?
    #checks the move direction times the assigned color direction
    return false if m_y * COLOR_DIRS[@color] <= 0 && !@king
    #wrong direction or jump wrong color
    return false if @board.board[s_y + unit_y][s_x + unit_x].nil? || @board.board[s_y + unit_y][s_x + unit_x].color == self.color
    # "jump not right size"
    return false if m_y != 2*unit_y && m_x != 2*unit_x

    #make jump, remove opponent from board

    @board.board[e_y][e_x] = self
    @board.board[s_y][s_x] = nil
    @board.board[s_y + unit_y][s_x + unit_x] = nil
    self.location = [e_y, e_x]
    maybe_promote

    true

  end

  def perform_moves(sequence)

    if valid_move_seq?(sequence)
      perform_moves!(sequence)
    else
      raise InvalidMoveError.new("Invalid move sequence")
    end

  end

  def perform_moves!(move_sequence)
    #take the move sequence and break it into pairs and run the perform slide, if it doesn't work try jump_method, if neither works then it's not a valid move.
    #Check on dup board then make move on real board if all the dup moves are true
    move_sequence.each do |move|
       (0...(move_sequence.length-1)).each do |idx|
        #technically not a next, but instead an error
        next if move[idx+1].nil?
        start_arr = move[idx]
        end_arr = move[idx+1]
        raise InvalidMoveError.new("Invalid move sequence") unless perform_slide(start_arr,end_arr) || perform_jump(start_arr, end_arr)
      end
    end
  end

  def valid_move_seq?(sequence)
    #calls perform_moves on duped piece/board; if no error raise return true, else false
    duped_board = @board.dup
    duped_piece = duped_board.board[self.location[0]][self.location[1]]

    begin
      duped_piece.perform_moves!(sequence)
    rescue InvalidMoveError
      return false
    end
    return true
  end


  def maybe_promote
    #call this after every jump and determine whether to change the king attribute to true
    return true if @king
    @king = @color == :b ? location[0] == 0 : location[0] == 7
  end

  def render
    "X"
  end

end

class Board
  attr_accessor :board

  def initialize empty = false
    @board = Array.new(8) {Array.new(8)} if empty
    #populate the board with pieces
  end

  def [](pos)
    i, j = pos
    @board[i][j]
  end

  def print_board
    color = :black
    piece_color_map = {:b => :cyan, :r => :magenta}


    @board.each_with_index do |row, row_idx|
      print (row_idx + 1).to_s + " "
      row.each_with_index do |piece, col_idx|
        # if these coordinates match the cursor coordinates, render cursour insteadg
        if piece.nil?
          print "| _ ".colorize(:background => color) # "\u2581"
        else
          print "| #{(piece.render + " ").colorize(:color => piece_color_map[piece.color], :background => color)}".colorize(:background => color)
        end
        color = color == :black ? :red : :black
      end
      puts

      color = color == :black ? :red : :black
    end
    puts "  | a | b | c | d | e | f | g | h "
  end

  def dup
    dup_board = Board.new(true)
    @board.each_with_index do |row, c_idx|
      row.each_with_index do |piece, r_idx|
        next if piece.nil?
        dup_board.board[c_idx][r_idx] = Piece.new(piece.color, piece.location, dup_board, piece.king)
      end
    end
    dup_board
  end

end

a = Board.new(true)
red1 = Piece.new(:r, [1,1], a)
red2 = Piece.new(:r, [3,1], a)
black1 = Piece.new(:b, [0,0], a, true)
a.board[1][1] = red1
a.board[0][0] = black1
a.board[3][1] = red2
a.print_board

p black1.perform_moves([[[0,0],[2,2]],[[2,2],[4,0]]])
# a.print_board
# p "this is #{black1.location} and king is #{black1.king}"
#
# p black1.perform_jump([2,2],[4,0])
a.print_board

