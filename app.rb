require "rubygems"
require "sinatra"
require "lib/game_sokoban"

LEVEL1 =  '
 #########
 #  #   .#
 #@$ $   #
 # $ ##..#
 #   #####
 #########'

get "/" do
  @level = LEVEL1
  erb :index
end


post "/" do
  game = GameSokoban.new
  game.set_level params[:level]
  game.sokoban_move params[:direction].to_sym
  @level = game.get_level
  erb :index
end
  
__END__

@@layout
<html>
  <head>
    <title>Ruby Game Sokoban</title>
  </head>
  <body>
    <h1>Ruby Game Sokoban</h1>
    <%= yield%>
    <br>
    <small>
      <a href="/">home</a>
      |
      <a href="https://github.com/nemilya/ruby-game-sokoban">github</a>
      |
      <a href="https://github.com/nemilya/ruby-game-sokoban/blob/master/spec/game_sokoban_spec.rb">rspec</a>
    </small>
  </body>
</html>

@@index
<form action="/" method="post">
<pre style="font-size: 20px"><%= @level %></pre>
<input type="hidden" name="level" value="<%= @level %>">

<table>
  <tr>
    <td></td>
    <td align="center"><input type="submit" name="direction" value="up"></td>
    <td></td>
  </tr>
  <tr>
    <td><input type="submit" name="direction" value="left"></td>
    <td></td>
    <td><input type="submit" name="direction" value="right"></td>
  </tr>
  <tr>
    <td></td>
    <td><input type="submit" name="direction" value="down"></td>
    <td></td>
  </tr>
</table>

</form>