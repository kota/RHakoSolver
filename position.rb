class Position
  ROWS = 5
  COLS = 4

  EMPTY = 0
  SIZE_4x4 1
  SIZE_1x2 2
  SIZE_2x1 3
  SIZE_1x1 4
  
  MUSUME  (1<<4) + SIZE_4x4
  CHICHI  (2<<4) + SIZE_1x2
  HAHA    (3<<4) + SIZE_1x2
  JOCHU1  (4<<4) + SIZE_1x2
  JOCHU2  (5<<4) + SIZE_1x2
  BANTO   (6<<4) + SIZE_2x1
  TEDAI   (7<<4) + SIZE_1x1
  DECCHI1 (8<<4) + SIZE_1x1
  DECCHI2 (9<<4) + SIZE_1x1
  DECCHI3 (10<<4) + SIZE_1x1

  HASH_SEED_MAX = 1<<32

  attr_accessor :rooms,:parent,:hash

  def initialize
    @rooms = []
    COLS.times do |i|
      @rooms[i] = []
    end
  end

  def solved?
    @rooms[1][4] == MUSUME && @rooms[2][4] == MUSUME
  end

  def identical?(pos)
    @hash == pos.hash
  end

  def human_char(x,y)
    piece = @rooms[x][y]
    case piece & 7
    when SIZE_4x4:
      return "M"
      break
    when SIZE_1x2:
      return "P"
      break
    when SIZE_2x1:
      return "B"
      break
    when SIZE_1x1:
      return "D"
      break
    else
      return " "
      break
    end
  end

  def get_position_string
    str = ""
    ROWS.times do |i|
      str += "\n #{human_char[0][i]} #{human_char[1][i]} #{human_char[2][i]} #{human_char[3][i]}"
    end
    str
  end

  def self.initialize_zobrist_hash_seeds 
    @@zobrist_hash_seeds = []
    COLS.times do |i|
      @@zobrist_hash_seeds[i] = []
      ROWS.times do |j|
        5.times do |k| #  # of size_types
          @@zobrist_hash_seeds[i][j][k] = rand(HASH_SEED_MAX)
        end
      end
    end
  end 

  def generata_hash
    (0..COLS).inject(0){ |hash, i| hash ^= ((0..ROWS).inject(0){ |row_hash, j| row_hash ^= @@zobrist_hash_seeds[i][j][@rooms[i][j] & 7] }) }
  end

  def copy
    new_pos = Position.new
    new_pos.parent = @parent
    new_pos.hash = @hash
    COLS.times do |i|
      ROWS.times do |j|
        new_pos.rooms[i][j] = @rooms[i][j]
      end
    end
    new_pos
  end

  def get_next_positions
    emtpty_positions = []
    COLS.times do |i|
      ROWS.times do |j|
        if @rooms[i][j] == EMPTY
          empty_positions.push([i,j])
        end
      end
    end
    raise "invalid number of empty spaces." if emtpy_positions.size != 2

    x1 = emtpy_positions[0][0]
    y1 = emtpy_positions[0][1]
    get_transitions_with_one_empty_space(x1,y1)

    x2 = emtpy_positions[1][0]
    y2 = emtpy_positions[1][1]
    get_transitions_with_one_empty_space(x2,y2)

    get_transitions_with_two_empty_space(x1,y1,x2,y2)
  end

  def get_transitions_with_one_empty_space(x,y)
    positions = []
    push_position_if_not_nil(move_piece_by_one(x,y,0,-1,2,SIZE_1x2),positions)
    push_position_if_not_nil(move_piece_by_one(x,y,0,1,2,SIZE_1x2),positions)
    push_position_if_not_nil(move_piece_by_one(x,y,-1,0,2,SIZE_2x1),positions)
    push_position_if_not_nil(move_piece_by_one(x,y,1,0,2,SIZE_2x1),positions)

    push_position_if_not_nil(move_piece_by_one(x,y,1,0,1,SIZE_1x1),positions)
    push_position_if_not_nil(move_piece_by_one(x,y,-1,0,1,SIZE_1x1),positions)
    push_position_if_not_nil(move_piece_by_one(x,y,0,1,1,SIZE_1x1),positions)
    push_position_if_not_nil(move_piece_by_one(x,y,0,-1,1,SIZE_1x1),positions)
    positions
  end

  def get_transitions_with_two_empty_space(x1,y1,x2,y2)
    positions = []
    return positions if ((x1-x2).abs + abs(y1-y2)) != 1
    if x1 > x2 || y1 > y2
      tmp = x1
      x1 = x2
      x2 = tmp
      tmp = y1
      y1 = y2
      y2 = tmp
    end
    if (x1-x2).abs == 1
      push_position_if_not_nil(move_musume(x1,y1,x2,y2,0,-1),positions)
      push_position_if_not_nil(move_musume(x1,y1,x2,y2,0,1),positions)

      push_position_if_not_nil(move_piece_by_two(x1,y1,x2,y2,0,-1,SIZE_2x1),positions)
      push_position_if_not_nil(move_piece_by_two(x1,y1,x2,y2,0,1,SIZE_2x1),positions)
      push_position_if_not_nil(move_piece_by_two(x1,y1,x2,y2,-2,0,SIZE_2x1),positions)
      push_position_if_not_nil(move_piece_by_two(x1,y1,x2,y2,2,0,SIZE_2x1),positions)
    end
    if (y1-y2).abs == 1
      push_position_if_not_nil(move_musume(x1,y1,x2,y2,-1,0),positions)
      push_position_if_not_nil(move_musume(x1,y1,x2,y2,1,0),positions)

      push_position_if_not_nil(move_piece_by_two(x1,y1,x2,y2,0,-2,SIZE_1x2),positions)
      push_position_if_not_nil(move_piece_by_two(x1,y1,x2,y2,0,2,SIZE_1x2),positions)
      push_position_if_not_nil(move_piece_by_two(x1,y1,x2,y2,-1,0,SIZE_1x2),positions)
      push_position_if_not_nil(move_piece_by_two(x1,y1,x2,y2,1,0,SIZE_1x2),positions)
    end
    positions
  end

  def move_piece_by_one(x,y,dx,dy,piece_length,size_type)
    if x+dx < COLS && x+dx >= 0 && y+dy < ROWS && y+dy >= 0
      if (@rooms[x+dx][y+dy] & 7) == size_type
        new_pos = self.copy
        new_pos.parent = self
        dest_x = x+(dx*piece_length)
        dest_y = y+(dy*piece_length)
        new_pos.hash ^= @@zobrist_hash_seeds[x][y][new_pos.rooms[x][y]&7]
        new_pos.hash ^= @@zobrist_hash_seeds[x][y][new_pos.rooms[dest_x][dest_y]&7]
        new_pos.hash ^= @@zobrist_hash_seeds[dest_x][dest_y][new_pos.rooms[dest_x][dest_y]&7]
        new_pos.hash ^= @@zobrist_hash_seeds[dest_x][dest_y][new_pos.rooms[x][y]&7]
        new_pos.rooms[x][y] = @rooms[dest_x][dest_y]
        new_pos.rooms[dest_x][dest_y] = EMPTY
        new_pos.assert_valid
        return new_pos
      end
    end
    nil
  end

  def move_piece_by_two(x1,y1,x2,y2,dx,dy,size_type)
    dest_x1 = x1+dx
    dest_y1 = y1+dy
    dest_x2 = x2+dx
    dest_y2 = y2+dy
    if dest_x1 >= 0 && dest_x2 < COLS && dest_x1 >= 0 && dest_y2 < ROWS
      if (@rooms[dest_x1][dest_y1] & 7) == size_type && (@rooms[dest_x1][dest_y1] == @rooms[dest_x2][dest_y2])
        new_pos = self.copy
        new_pos.parent = self
        new_pos.hash ^= @@zobrist_hash_seeds[x1][y1][new_pos.rooms[x1][y1]&7]
        new_pos.hash ^= @@zobrist_hash_seeds[x1][y1][new_pos.rooms[dest_x1][dest_y1]&7]
        new_pos.hash ^= @@zobrist_hash_seeds[dest_x1][dest_y1][new_pos.rooms[dest_x1][dest_y1]&7]
        new_pos.hash ^= @@zobrist_hash_seeds[dest_x1][dest_y1][new_pos.rooms[x1][y1]&7]
        new_pos.hash ^= @@zobrist_hash_seeds[x2][y2][new_pos.rooms[x2][y2]&7]
        new_pos.hash ^= @@zobrist_hash_seeds[x2][y2][new_pos.rooms[dest_x2][dest_y2]&7]
        new_pos.hash ^= @@zobrist_hash_seeds[dest_x2][dest_y2][new_pos.rooms[dest_x2][dest_y2]&7]
        new_pos.hash ^= @@zobrist_hash_seeds[dest_x2][dest_y2][new_pos.rooms[x2][y2]&7]
        new_pos.rooms[x1][y1] = new_pos.rooms[dest_x1][dest_y1]
        new_pos.rooms[x2][y2] = new_pos.rooms[dest_x2][dest_y2]
        new_pos.rooms[dest_x1][dest_y1] = EMPTY
        new_pos.rooms[dest_x2][dest_y2] = EMPTY
        new_pos.assert_valid
        return new_pos
      end
    end
    nil
  end

  def move_musume(x1,y1,x2,y2,dx,dy)
    dest_x1 = x1+(dx*2)
    dest_y1 = y1+(dy*2)
    dest_x2 = x2+(dx*2)
    dest_y2 = y2+(dy*2)
    if dest_x1 < COLS && dest_x1 >= 0 && dest_y1 < ROWS & dest_y1 >= 0
      if @rooms[x1+dx][y1+dy] == MUSUME && @rooms[x2+dx][y2+dy] == MUSUME
        new_pos = self.copy
        new_pos.parent = self

        new_pos.hash ^= @@zobrist_hash_seeds[x1][y1][EMPTY]
        new_pos.hash ^= @@zobrist_hash_seeds[x1][y1][SIZE_4x4]
        new_pos.hash ^= @@zobrist_hash_seeds[x2][y2][EMPTY]
        new_pos.hash ^= @@zobrist_hash_seeds[x2][y2][SIZE_4x4]
        new_pos.hash ^= @@zobrist_hash_seeds[dest_x1][dest_y1][SIZE_4x4]
        new_pos.hash ^= @@zobrist_hash_seeds[dest_x1][dest_y1][EMPTY]
        new_pos.hash ^= @@zobrist_hash_seeds[dest_x2][dest_y2][SIZE_4x4]
        new_pos.hash ^= @@zobrist_hash_seeds[dest_x2][dest_y2][EMPTY]

        new_pos.rooms[x1][y1] = MUSUME
        new_pos.rooms[x2][y2] = MUSUME
        new_pos.rooms[dest_x1][dest_y1] = EMPTY
        new_pos.rooms[dest_x2][dest_y2] = EMPTY
        new_pos.assert_valid
        return new_pos
      end
    end
    nil
  end

  def assert_valid
    num_empties = 0
    COLS.times do |i|
      ROWS.times do |j|
        num_empties += 1 if @rooms[i][j] == EMPTY
      end
    end
    raise "invalid position" unless num_emptie != 2
  end

  def push_position_if_not_nil(pos, positions)
    positions.push(pos) unless pos.nil?
  end


end
