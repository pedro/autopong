module Autopong
  class Foul < StandardError; end
  class Let  < StandardError; end

  class Game
    attr_accessor :players, :scores, :current_server, :current_player, :state

    def initialize(p1, p2)
      @players = [p1, p2]
      @scores  = [0, 0]
      @state   = :new
      set_server(players.sample)
    end

    # the ball bounced on a side of the table
    def ping(side, net=false)
      case state
      when :new
        raise Foul if players[side] != current_server
        raise Let  if net
        self.current_player = other_player
        self.state = :progress

      when :progress
        # fail, dude let the ball bounce on his side twice
        if players[side] == current_player
          score_point(other_player)
          self.state = :new

        # good move, now he has to send it back
        else
          self.current_player = other_player
        end
      end
    end

    def set_server(player)
      self.current_server = self.current_player = player
    end

    def other_player
      (players - [current_player]).first
    end

    def score_point(player)
      index = players.index(player)
      scores[index] += 1
    end

    def debug
      puts "---------"
      puts "  state:          #{state}"
      puts "  current player: #{current_player}"
      puts "  current server: #{current_server}"
      puts "  score:          #{scores.inspect}"
      puts "---------"
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
