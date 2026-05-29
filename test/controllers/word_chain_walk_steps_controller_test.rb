require "test_helper"

class WordChainWalkStepsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @word_chain_walk_step = word_chain_walk_steps(:one)
  end

  test "should get index" do
    get word_chain_walk_steps_url
    assert_response :success
  end

  test "should get new" do
    get new_word_chain_walk_step_url
    assert_response :success
  end

  test "should create word_chain_walk_step" do
    assert_difference("WordChainWalkStep.count") do
      post word_chain_walk_steps_url, params: { word_chain_walk_step: { index: @word_chain_walk_step.index, latitude: @word_chain_walk_step.latitude, longitude: @word_chain_walk_step.longitude, memo: @word_chain_walk_step.memo, word: @word_chain_walk_step.word, word_chain_walk_id: @word_chain_walk_step.word_chain_walk_id } }
    end

    assert_redirected_to word_chain_walk_step_url(WordChainWalkStep.last)
  end

  test "should show word_chain_walk_step" do
    get word_chain_walk_step_url(@word_chain_walk_step)
    assert_response :success
  end

  test "should get edit" do
    get edit_word_chain_walk_step_url(@word_chain_walk_step)
    assert_response :success
  end

  test "should update word_chain_walk_step" do
    patch word_chain_walk_step_url(@word_chain_walk_step), params: { word_chain_walk_step: { index: @word_chain_walk_step.index, latitude: @word_chain_walk_step.latitude, longitude: @word_chain_walk_step.longitude, memo: @word_chain_walk_step.memo, word: @word_chain_walk_step.word, word_chain_walk_id: @word_chain_walk_step.word_chain_walk_id } }
    assert_redirected_to word_chain_walk_step_url(@word_chain_walk_step)
  end

  test "should destroy word_chain_walk_step" do
    assert_difference("WordChainWalkStep.count", -1) do
      delete word_chain_walk_step_url(@word_chain_walk_step)
    end

    assert_redirected_to word_chain_walk_steps_url
  end
end
