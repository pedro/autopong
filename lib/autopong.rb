module Autopong
  class Foul < StandardError; end

  class Game
    attr_accessor :players, :current_player, :state

    def initialize(p1, p2)
      @players = [p1, p2]
      @scores  = [0, 0]
      @current_player = players.sample
      @state = :new
    end

    # the ball bounced on a side of the table
    def ping(side)
      case state
      when :new
        raise Foul if players[side] != current_player
        self.current_player = @players[(side + 1) % 2]
        self.state = :progress
      end
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
