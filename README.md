Autopong
========

A Ruby engine implementing the rules of ping pong.

Usage
-----

Use as a backend for your game or whatever:

```ruby
p1   = Autopong::Player.new("John Malkovich")
p2   = Autopong::Player.new("Edward Norton")
game = Autopong::Game.new(p1, p2)

# the game will pick a random player to serve
puts "serve, #{game.current_server}"

# ping means the ball hit the table
# accepted values are:
#   0: ball hit the p1 side
#   1: ball hit the p2 side
game.ping(0)

# out means the ball went outside
game.out

# at any time you can check the score
game.score # => [0, 1]

# check the game state
game.state # => :serve (other values are :ended and :progress)

# and the winner, if any
game.winner # => nil (would return a player if any
```

Check `bin/game` for a proxy that can be used with hardware hooked up to your table:

```
bin/game "John Malkovich" "Edward Norton"

current match : John Malkovich vs Edward Norton
serve         : John Malkovich
interactive mode ===
  s : left (John Malkovich side)
  d : out
  f : right (Edward Norton side)
-> s
   good move from John Malkovich
```

About
-----

Written by Pedro Belo.
Licensed as MIT.
