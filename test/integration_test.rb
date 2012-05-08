describe "Integration test" do
  before do
    @p1 = Player.new("p1")
    @p2 = Player.new("p2")
    @game = Game.new(@p1, @p2)
  end

  it "handles a full match" do
    @game.set_server(@p2)
    @game.state.must_equal :serve

    # 1: p2 serves, receives, fails to send it back
    @game.ping(1)
    @game.state.must_equal :progress
    @game.ping(0)
    @game.state.must_equal :progress
    @game.ping(1)
    @game.state.must_equal :progress
    @game.ping(1) # failed to return
    @game.scores.must_equal [1, 0]
    @game.current_server.must_equal @p2

    # 2: p2 serves, p1 fails to send it back
    @game.ping(1)
    @game.ping(0)
    @game.ping(0)
    @game.scores.must_equal [1, 1]
    @game.current_server.must_equal @p1

    # 3: p1 serves let
    lambda { @game.ping(0, true) }.must_raise(Let)
    @game.scores.must_equal [1, 1]
    @game.current_server.must_equal @p1

    # 3: p1 serves, gets back, fails to return
    @game.ping(0)
    @game.ping(1)
    @game.ping(0)
    @game.ping(0)
    @game.scores.must_equal [1, 2]
    @game.current_server.must_equal @p1

    # 4: p1 serves out
    @game.out
    @game.scores.must_equal [1, 3]
    @game.current_server.must_equal @p2

    # 5: p2 serves out (after bouncing on his side)
    @game.ping(1)
    @game.out
    @game.scores.must_equal [2, 3]
    @game.current_server.must_equal @p2

    # 6: p2 serves and p1 returns out
    @game.ping(1)
    @game.ping(0)
    @game.out
    @game.scores.must_equal [2, 4]
    @game.current_server.must_equal @p1

    # 7 on - p1 gets drunk
    @game.out
    @game.scores.must_equal [2, 5]
    @game.out
    @game.scores.must_equal [2, 6]

    @game.ping(1)
    @game.ping(0)
    @game.out
    @game.scores.must_equal [2, 7]
    @game.ping(1)
    @game.ping(0)
    @game.out
    @game.scores.must_equal [2, 8]

    @game.out
    @game.scores.must_equal [2, 9]
    @game.out
    @game.scores.must_equal [2, 10]

    @game.ping(1)
    @game.ping(0)
    @game.out
    @game.scores.must_equal [2, 11]
    @game.winner.must_equal @p2
    @game.state.must_equal :ended
  end
end
