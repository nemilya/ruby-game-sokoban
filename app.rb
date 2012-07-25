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


post "/move" do
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
    <%= yield%>
  </body>
</html>

@@index
<form action="/move" method="post">
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