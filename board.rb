
class Board
  attr_accessor :board

  def initialize empty = false
    @board = Array.new(8) {Array.new(8)} if empty
    populate_board unless empty
  end

  def populate_board
    @board = Array.new(8) {Array.new(8)}

    turn = :r

    3.times do |row_idx|
      8.times do |col_idx|
        turn = (turn == :b) ? :r : :b
        if turn == :b
          @board[col_idx][row_idx] = Piece.new(:b,[col_idx,row_idx],self)
        else
          @board[col_idx][7-row_idx] = Piece.new(:r,[col_idx,(7-row_idx)],self)
        end
      end
      turn = (turn == :b) ? :r : :b
    end
  end

  def [](pos)
    i, j = pos
    @board[i][j]
  end

  def print_board
    color = :black
    piece_color_map = {:b => :white, :r => :red}


    @board.each_with_index do |row, row_idx|
      print (row_idx).to_s + " "
      row.each_with_index do |piece, col_idx|
        if piece.nil?
          print "| _ ".colorize(:background => color)
        else
          print "| #{(piece.render + " ").colorize(:color => piece_color_map[piece.color], :background => color)}".colorize(:background => color)
        end
        color = color == :black ? :red : :black
      end
      puts

      color = color == :black ? :red : :black
    end
    puts "  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 "
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