class GameSokoban

  WALL    = '#'
  SOKOBAN = '@'
  FREE    = ' '
  BOX     = '$'
  GOAL    = '.'

  BOX_ON_GOAL     = '*'
  SOKOBAN_ON_GOAL = '+'

  VALID_CELLS = [WALL, SOKOBAN, FREE, BOX, GOAL, BOX_ON_GOAL, SOKOBAN_ON_GOAL]

  GOAL_ITEMS    = [GOAL, BOX_ON_GOAL, SOKOBAN_ON_GOAL]
  BOX_ITEMS     = [BOX, BOX_ON_GOAL]
  SOKOBAN_ITEMS = [SOKOBAN, SOKOBAN_ON_GOAL]

  DIRECTIONS = {
    :up    => {:row=>-1},
    :down  => {:row=> 1},
    :left  => {:col=>-1},
    :right => {:col=> 1}
  }

  def initialize
    @cells = [] # rows[cols[]]
    @info = {}
    @sokoban_pos = {} # :col, :row
    @goals = [] # {:cols, :row}
    @walls = [] # {:cols, :row}
    @boxes = [] # {:cols, :row}
  end

  def boxes
    @boxes
  end

  def set_level(level)
    @cells = []
    level.split("\n").each do |row|
      elements_in_row = row.chomp.split('')
      @cells << elements_in_row if elements_in_row.size > 0
    end
    _init
  end

  
  def _init
    @info[:box_cnt]         = 0
    @info[:sokoban_cnt]     = 0
    @info[:goals_cnt]       = 0
    @info[:box_on_goal_cnt] = 0
    @cells.each_with_index do |row,   row_pos|
      row.each_with_index  do |cell,  col_pos|
        cur_pos = {:col=>col_pos, :row=>row_pos}

        @sokoban_pos = cur_pos if SOKOBAN_ITEMS.include?(cell)
        @goals << cur_pos      if GOAL_ITEMS.include?(cell)
        @boxes << cur_pos      if BOX_ITEMS.include?(cell)
        @walls << cur_pos      if cell == WALL

        @info[:box_cnt] += 1         if BOX_ITEMS.include?(cell)
        @info[:box_on_goal_cnt] += 1 if cell == BOX_ON_GOAL
        @info[:sokoban_cnt] += 1     if SOKOBAN_ITEMS.include?(cell)
        @info[:goals_cnt] += 1       if GOAL_ITEMS.include?(cell)
      end
    end
  end

  def element_at_pos(pos)
    @cells[pos[:row]][pos[:col]]
  end

  def info
    @info
  end

  def level_valid?
    _info = info
    return \
      _info[:sokoban_cnt] == 1 \
      && _info[:box_cnt] > 0 \
      && _info[:box_cnt] == _info[:goals_cnt]
  end

  # :max_col=>, :max_row=>
  def level_size
    r = []
    c = []
    els = [@sokoban_pos] + @goals + @walls + @boxes
    els.each do |el|
      r << el[:row]
      c << el[:col]
    end
    {:max_col=>c.max, :max_row=>r.max}
  end

  def get_level
    refresh_cells # inner objects to @cells
    cells2ascii
  end

  def get_cell_at(pos)
    return WALL if is_wall_at_pos?(pos)

    if is_sokoban_at_pos?(pos)
      return SOKOBAN_ON_GOAL if is_goal_at_pos?(pos)
      return SOKOBAN
    end
    if is_box_at_pos?(pos)
      return BOX_ON_GOAL if is_goal_at_pos?(pos)
      return BOX
    end
    return GOAL if is_goal_at_pos?(pos)
    FREE
  end

  def is_wall_at_pos?(pos)
    @walls.each do |wall|
      return true if wall == pos
    end
    false
  end

  def is_box_at_pos?(pos)
    @boxes.each do |box|
      return true if box == pos
    end
    false
  end

  def is_goal_at_pos?(pos)
    @goals.each do |goal|
      return true if goal == pos
    end
    false
  end

  def is_sokoban_at_pos?(pos)
    @sokoban_pos == pos
  end


  # inner objects to @cells
  def refresh_cells
    new_cells = []
    _level_size = level_size
    (0.._level_size[:max_row]).each do |row_pos|
      new_cells[row_pos] = []
      (0.._level_size[:max_col]).each do |col_pos|
        cur_pos = {:col=>col_pos, :row=>row_pos}
        cell = get_cell_at(cur_pos)
        raise "Invalid cell: '#{cell}'" unless VALID_CELLS.include?(cell)
        new_cells[row_pos][col_pos] = cell
      end
    end
    @cells = new_cells
  end

  def cells2ascii
    ret = ''
    @cells.each do |row|
      ret << row.join('') << "\n"
    end
    ret.chop
  end

  def sokoban_pos
    @sokoban_pos
  end

  def valid_direction?(direction)
    DIRECTIONS.keys.include?(direction)
  end

  def _get_new_pos(pos, direction)
    new_pos = pos.clone
    vector = DIRECTIONS[direction]
    vector.each do |k,d|
      new_pos[k] += d
    end
    new_pos
  end

  def _new_sokoban_pos(direction)
    _get_new_pos @sokoban_pos, direction
  end

  def sokoban_move(direction)
    return nil unless valid_direction?(direction)
    new_pos = _new_sokoban_pos(direction)
    element_at_pos = element_at_pos(new_pos)
    if [FREE, GOAL].include?(element_at_pos)
      @sokoban_pos = new_pos
    end

    if element_at_pos == BOX
      if is_box_movable?(new_pos, direction)
        move_box(new_pos, direction)
        @sokoban_pos = new_pos
      end
    end
  end

  def get_box_at(position)
    @boxes.each do |box|
      return box if box == position
    end
  end

  def move_box(pos, direction)
    box = get_box_at(pos)
    vector = DIRECTIONS[direction]
    vector.each do |k,d|
      box[k] += d
    end
  end

  def is_box_movable?(position, direction)
    element_at_pos = element_at_pos _get_new_pos(position, direction)
    return true if [FREE, GOAL].include?(element_at_pos)
    false
  end

end