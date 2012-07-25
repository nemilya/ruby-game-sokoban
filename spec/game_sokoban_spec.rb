require 'spec_helper'
require 'game_sokoban'

# корректный уровень
LEVEL1 = '#######'+"\n"+
         '#@ $ .#'+"\n"+
         '#######'

# в уровне больше Целей чем Ящиков
LEVEL2 = '#######'+"\n"+
         '#   +*#'+"\n"+
         '#######'

# 
LEVEL3 = '#####'+"\n"+
         '#   #'+"\n"+
         '# @ #'+"\n"+
         '#   #'+"\n"+
         '#####'


describe GameSokoban do
  describe "загрузка уровня" do
    it "наличие элемента в ячейкее" do
      game = GameSokoban.new
      game.set_level LEVEL1
      game.element_at_pos({:col=>0, :row=>0}).should == GameSokoban::WALL
      game.element_at_pos({:col=>1, :row=>1}).should == GameSokoban::SOKOBAN
      game.element_at_pos({:col=>2, :row=>1}).should == GameSokoban::FREE
      game.element_at_pos({:col=>3, :row=>1}).should == GameSokoban::BOX
      game.element_at_pos({:col=>5, :row=>1}).should == GameSokoban::GOAL

      game.set_level LEVEL2
      game.element_at_pos({:col=>4, :row=>1}).should == GameSokoban::SOKOBAN_ON_GOAL
      game.element_at_pos({:col=>5, :row=>1}).should == GameSokoban::BOX_ON_GOAL
    end

    it "информация по уровню" do
      game = GameSokoban.new
      game.set_level LEVEL1
      game.info[:box_cnt].should     == 1
      game.info[:sokoban_cnt].should == 1
      game.info[:goals_cnt].should   == 1
      game.info[:box_on_goal_cnt].should == 0
      
      game.set_level LEVEL2
      game.info[:box_cnt].should     == 1
      game.info[:sokoban_cnt].should == 1
      game.info[:goals_cnt].should   == 2
      game.info[:box_on_goal_cnt].should == 1
    end

    it "размер уровня" do
      game = GameSokoban.new
      game.set_level LEVEL1
      game.level_size.should == {:max_row=>2, :max_col=>6}
    end

    it "валидный уровень, если есть 1 Сокобан, по крайней мере один ящик, и целей по количеству ящиков" do
      game = GameSokoban.new
      game.set_level LEVEL1
      game.level_valid?.should be_true
    end

    it "не валидный уровень" do
      game = GameSokoban.new
      game.set_level LEVEL2
      game.level_valid?.should be_false
    end

    it "#get_cell_at" do
      game = GameSokoban.new
      game.set_level LEVEL1

      # based on inner objects
      game.get_cell_at({:col=>1, :row=>1}).should == GameSokoban::SOKOBAN
      game.get_cell_at({:col=>0, :row=>0}).should == GameSokoban::WALL
      game.get_cell_at({:col=>3, :row=>1}).should == GameSokoban::BOX
      game.get_cell_at({:col=>5, :row=>1}).should == GameSokoban::GOAL

    end

    it "получение уровня" do
      game = GameSokoban.new
      game.set_level LEVEL1
      game.get_level.should == LEVEL1
    end

  end

  describe "Сокобан" do
    it "местоположение" do
      game = GameSokoban.new
      game.set_level LEVEL1
      game.sokoban_pos.should == {:col=>1, :row=>1}
    end

    it "#valid_direction?" do
      game = GameSokoban.new
      game.valid_direction?(:up).should    be_true
      game.valid_direction?(:down).should  be_true
      game.valid_direction?(:left).should  be_true
      game.valid_direction?(:right).should be_true

      game.valid_direction?(:jump).should be_false
    end

    describe "свободное передвижение" do
      it "вверх" do
        game = GameSokoban.new
        game.set_level LEVEL3
        game.sokoban_pos.should == {:col=>2, :row=>2}

        game.sokoban_move :up
        game.sokoban_pos.should == {:col=>2, :row=>1}
      end

      it "вниз" do
        game = GameSokoban.new
        game.set_level LEVEL3
        game.sokoban_pos.should == {:col=>2, :row=>2}

        game.sokoban_move :down
        game.sokoban_pos.should == {:col=>2, :row=>3}
      end

      it "влево" do
        game = GameSokoban.new
        game.set_level LEVEL3
        game.sokoban_pos.should == {:col=>2, :row=>2}

        game.sokoban_move :left
        game.sokoban_pos.should == {:col=>1, :row=>2}
      end

      it "вправо" do
        game = GameSokoban.new
        game.set_level LEVEL3
        game.sokoban_pos.should == {:col=>2, :row=>2}

        game.sokoban_move :right
        game.sokoban_pos.should == {:col=>3, :row=>2}
      end
    end

    describe "перемещения на стену" do
      it "координаты не меняются" do
        game = GameSokoban.new
        game.set_level LEVEL1
        initial_pos = game.sokoban_pos.clone

        game.sokoban_move :up
        game.sokoban_pos.should == initial_pos

        game.sokoban_move :down
        game.sokoban_pos.should == initial_pos
      
        game.sokoban_move :left
        game.sokoban_pos.should == initial_pos
      end
    end

    describe "перемещение ящика" do
      describe "#is_box_movable?" do
        it "перемещение возможно" do
          game = GameSokoban.new
          game.set_level '#@$ #'
          game.is_box_movable?({:col=>2, :row=>0}, :right).should == true
        end

        it "перемещение невозможно - стена" do
          game = GameSokoban.new
          game.set_level '#@$#'
          game.is_box_movable?({:col=>2, :row=>0}, :right).should == false
        end
      end

      it "#boxes" do
        game = GameSokoban.new
        game.set_level '#@$ #'
        game.boxes.should == [{:col=>2, :row=>0}]
      end



      it "свободное" do
        game = GameSokoban.new
        game.set_level '#@$ #'
        game.sokoban_move :right

        game.get_level.should == \
                       '# @$#'
      end

      it "нельзя переместить - другой ящик" do
        game = GameSokoban.new
        game.set_level '#@$$#'
        game.sokoban_move :right

        game.get_level.should == \
                       '#@$$#'
      end
    end

  end
end