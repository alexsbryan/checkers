class Piece
  attr_accessor :color, :location, :king
  COLOR_DIRS = {
    :r => -1,
    :b => 1
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
    s_y, s_x = start_pos
    e_y, e_x = end_pos
    m_y, m_x = move_diffs(start_pos, end_pos)

    return false if @board.board[s_y][s_x].nil?
    return false if (m_x).abs > 1 || (m_y).abs > 1
    return false if !@board.board[e_y][e_x].nil?
    return false if m_x * COLOR_DIRS[@color] <= 0 && !@king

    @board.board[e_y][e_x] = self
    @board.board[s_y][s_x] = nil
    self.location = [e_y, e_x]
    maybe_promote

    true
  end

  def perform_jump(start_pos, end_pos)
    s_y, s_x = start_pos
    e_y, e_x = end_pos
    m_y, m_x = move_diffs(start_pos, end_pos)
    unit_y, unit_x = [m_y/m_y.abs,m_x/m_x.abs]

    return false if @board.board[s_y][s_x].nil?
    return false if !@board.board[e_y][e_x].nil?
    return false if m_x * COLOR_DIRS[@color] <= 0 && !@king
    return false if @board.board[s_y + unit_y][s_x + unit_x].nil? || @board.board[s_y + unit_y][s_x + unit_x].color == self.color
    return false if m_y != 2*unit_y && m_x != 2*unit_x

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
    prev_end = []

    move_sequence.each_with_index do |move, r|
      p move
      (0...(move_sequence.length)).each do |idx|

        next if move[idx+1].nil?
        start_arr = move[idx]
        end_arr = move[idx+1]
        p start_arr
        p prev_end
        p end_arr
        p r
        raise InvalidMoveError.new("No cheating") if prev_end != start_arr && r > 0
        raise InvalidMoveError.new("Invalid move sequence") unless perform_slide(start_arr,end_arr) || perform_jump(start_arr, end_arr)
        prev_end = end_arr
      end
    end
  end

  def valid_move_seq?(sequence)
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
    return true if @king
    @king = @color == :b ? location[0] == 0 : location[0] == 7
  end

  def render
    if king
      "O"
    else
      "X"
    end
  end

end
