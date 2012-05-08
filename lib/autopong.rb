module Autopong
  class Foul < StandardError; end
  class Let  < StandardError; end

  class Game
    attr_accessor :players, :scores, :current_player, :state

    def initialize(p1, p2)
      @players = [p1, p2]
      @scores  = [0, 0]
      @current_player = players.sample
      @state = :new
    end

    # the ball bounced on a side of the table
    def ping(side, net=false)
      other = other_player(side)

      case state
      when :new
        raise Foul if players[side] != current_player
        raise Let  if net
        self.current_player = other
        self.state = :progress

      when :progress
        # fail, dude let the ball bounce on his side twice
        if players[side] == current_player
          score_point(other)
          self.state = :new

        # good move, now he has to send it back
        else
          self.current_player = other
        end
      end
    end

    def other_player(side)
      players[(side + 1) % 2]
    end

    def score_point(player)
      index = players.index(player)
      scores[index] += 1
    end
  end

  class Player
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def to_s
      name
    end
  end
end
