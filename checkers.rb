require 'colorize'
require_relative 'piece'
require_relative 'board'

class InvalidMoveError < ArgumentError

end

class Game

  def initialize
    @board = Board.new
    @red = HumanPlayer.new(@board, :r)
    @black = HumanPlayer.new(@board, :b)
  end

  def play
    until won?
      @board.print_board
      @black.play_turn
      if won?
        puts "Congrats BLACK won!"
        return
      end
      @board.print_board
      @red.play_turn
    end
    puts "Congrats RED won!"
  end


  def won?
    player_colors = []
    @board.board.each_with_index do |row,r_index|
      row.each_with_index do |piece, c_index|
        next if piece.nil?
        player_colors << piece.color
      end
    end
    return (player_colors.none? {|x| x == :b} || player_colors.none? {|x| x == :b})
  end
end

class HumanPlayer
  def initialize board, color
    @board = board
    @color = color
  end

  def play_turn
    begin
      move_arr = []
      move_type = "j"
      until move_type == "x"
        move_arr << get_coords[0]
        puts "Enter x to finish move, or j to make a jump and enter more coordinates"
        move_type = gets.chomp.downcase
      end
      p move_arr
      start_pos = [move_arr.flatten[0],move_arr.flatten[1]]
      raise InvalidMoveError.new("Invalid move sequence") if @color != @board.board[start_pos[0]][start_pos[1]].color
      @board.board[start_pos[0]][start_pos[1]].perform_moves(move_arr)
    rescue InvalidMoveError => e
      play_turn
    end
  end

  def get_coords
    move_arr = []
    puts "It's #{@color}'s turn. Please enter your move: (e.g 0,2 & 1,3 (down, right) and for jumps separate moves by ;)"
    puts "Enter start coordinates (1,2 format)"
    start_coords = gets.chomp
    start_coords = start_coords.split(",").map {|num| num.to_i}
    puts "Enter end coordinates (1,2 format)"
    end_coords = gets.chomp
    end_coords = end_coords.split(",").map {|num| num.to_i}
    move_arr << [start_coords,end_coords]
  end

  def parse(user_input)

    coordinates = []
    moves = user_input.split(';')
    spaces = moves.split("&")
    nums =
    moves.each do |move|
      coordinates << [move]
    end
    coordinates
  end

end

a = Game.new

a.play


# # p a.board[0][2].perform_moves([[[0,2],[1,3]],[[2,2],[3,3]]])
# p a.board[1][5].perform_moves([[[1,5],[2,4]]])
# p a.board[7][5].perform_slide([1,5],[2,4])
# a.print_board
#
# # red1 = Piece.new(:r, [1,1], a)
# # red2 = Piece.new(:r, [3,1], a)
# # black1 = Piece.new(:b, [0,0], a, true)
# # a.board[1][1] = red1
# # a.board[0][0] = black1
# # a.board[3][1] = red2
# # a.print_board
# #
# # p black1.perform_moves([[[0,0],[2,2]],[[2,2],[4,0]]])
#
# #format perform moves  perform_moves([[[],[]],[[],[]]]) one big array of arrays of arrays
#
# # a.print_board
# # p "this is #{black1.location} and king is #{black1.king}"
# #
# # p black1.perform_jump([2,2],[4,0])
# a.print_board

