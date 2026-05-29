require "test_helper"

class WordChainWalksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @word_chain_walk = word_chain_walks(:one)
  end

  test "should get index" do
    get word_chain_walks_url
    assert_response :success
  end

  test "should get new" do
    get new_word_chain_walk_url
    assert_response :success
  end

  test "should create word_chain_walk" do
    assert_difference("WordChainWalk.count") do
      post word_chain_walks_url, params: { word_chain_walk: { finished_at: @word_chain_walk.finished_at, start_char: @word_chain_walk.start_char, started_at: @word_chain_walk.started_at } }
    end

    assert_redirected_to word_chain_walk_url(WordChainWalk.last)
  end

  test "should show word_chain_walk" do
    get word_chain_walk_url(@word_chain_walk)
    assert_response :success
  end

  test "should get edit" do
    get edit_word_chain_walk_url(@word_chain_walk)
    assert_response :success
  end

  test "should update word_chain_walk" do
    patch word_chain_walk_url(@word_chain_walk), params: { word_chain_walk: { finished_at: @word_chain_walk.finished_at, start_char: @word_chain_walk.start_char, started_at: @word_chain_walk.started_at } }
    assert_redirected_to word_chain_walk_url(@word_chain_walk)
  end

  test "should destroy word_chain_walk" do
    assert_difference("WordChainWalk.count", -1) do
      delete word_chain_walk_url(@word_chain_walk)
    end

    assert_redirected_to word_chain_walks_url
  end
end
