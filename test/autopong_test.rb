require "test_helper"

describe Game do
  before do
    @p1 = Player.new("p1")
    @p2 = Player.new("p2")
    @game = Game.new(@p1, @p2)
    @game.set_server(@p1)
  end

  it "starts on state serve" do
    @game.state.must_equal :serve
  end

  it "has a current player randomly picked to start the game" do
    [@p1, @p2].must_include @game.current_server
  end

  it "also considers the player serving to be the current" do
    @game.current_server.must_equal @game.current_player
  end

  describe "winner" do
    describe "when the score is below 11" do
      it "doesn't have a winner" do
        @game.scores = [2, 10]
        @game.winner.must_be_nil
      end
    end

    describe "when a player reached 11 and the other is below 10" do
      it "declares that player the winner" do
        @game.scores = [8, 11]
        @game.winner.must_equal @p2
      end
    end

    describe "when both players are above 10" do
      it "declares the winner a player that gets two points in the lead" do
        @game.scores = [10, 12]
        @game.winner.must_equal @p2
      end

      it "doesn't have a winner for a smaller difference" do
        @game.scores = [17, 18]
        @game.winner.must_be_nil
      end
    end
  end

  describe "scoring" do
    it "increases the player score" do
      @game.score_point(@p1)
      @game.scores.must_equal [1, 0]
    end

    it "sets the state to ended if there's a winner" do
      @game.scores = [8, 10]
      @game.score_point(@p2)
      @game.state.must_equal :ended
    end

    it "returns state to serve otherwise" do
      @game.score_point(@p1)
      @game.state.must_equal :serve
    end

    it "changes to the next server after 2 serves" do
      @game.serves = 1
      @game.score_point(@p2)
      @game.current_server.must_equal @p2
    end

    it "changes to the next server after every serve after 10x10" do
      @game.scores = [10, 10]
      @game.score_point(@p1)
      @game.current_server.must_equal @p2
    end
  end

  describe "on a serve" do
    describe "when the ball starts in the wrong side of the table" do
      it "raises a foul" do
        lambda { @game.ping(1) }.must_raise(Foul)
      end
    end

    describe "when the ball starts in the right side" do
      before { @game.ping(0) }

      it "moves state to progress" do
        @game.state.must_equal :progress
      end
    end

    describe "when the ball hits the net" do
      it "raises a let" do
        lambda { @game.ping(0, true) }.must_raise(Let)
      end
    end

    describe "the ball goes out" do
      before { @game.out }

      it "is a score for the other player" do
        @game.scores.must_equal [0, 1]
      end
    end
  end

  describe "on a game in progress" do
    before { @game.state = :progress }

    describe "when the ball hits the same side again" do
      before { @game.ping(0) }

      it "considers it a score for the other player" do
        @game.scores.must_equal [0, 1]
      end

      it "goes back to state serve" do
        @game.state.must_equal :serve
      end
    end

    describe "when the ball hits the other side" do
      before { @game.ping(1) }

      it "keeps the game in progress" do
        @game.state.must_equal :progress
      end

      it "flips the current player" do
        @game.current_player.must_equal @p2
      end

      it "doesn't change the score" do
        @game.scores.must_equal [0, 0]
      end
    end

    describe "when the ball hits the net" do
      it "ignores" do
        @game.ping(1, true) # should not raise
      end
    end

    describe "the ball goes out" do
      before { @game.out }

      it "is a point for the other player" do
        @game.scores.must_equal [0, 1]
      end

      it "goes back to state serve" do
        @game.state.must_equal :serve
      end
    end
  end
end
