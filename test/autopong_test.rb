require "test_helper"

describe Game do
  before do
    @p1 = Player.new("John Malkovich")
    @p2 = Player.new("Edward Norton")
    @game = Game.new(@p1, @p2)
  end

  it "starts on state new" do
    @game.state.must_equal :new
  end

  it "has a current player randomly picked to start the game" do
    [@p1, @p2].must_include @game.current_player
  end

  describe "on a new game" do
    before do
      @game.current_player = @p1
    end

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

      it "changes current player" do
        @game.current_player.must_equal @p2
      end
    end

    describe "on a game in progress" do
      before do
        @game.state = :progress
        @game.current_player = @p1
      end

      describe "when the ball hits the same side again" do
        before { @game.ping(0) }

        it "considers it a score for the other player" do
          @game.scores.must_equal [0, 1]
        end

        it "goes back to state new" do
          @game.state.must_equal :new
        end
      end

      describe "when the ball hits the other side" do
        before { @game.ping(1) }

        it "keeps the game in progress" do
          @game.state.must_equal :progress
        end

        it "flips the current player" do
          @game.current_player.must_equal @p1
        end

        it "doesn't change the score" do
          @game.scores.must_equal [0, 0]
        end
      end
    end
  end
end
