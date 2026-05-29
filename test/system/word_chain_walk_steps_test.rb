require "application_system_test_case"

class WordChainWalkStepsTest < ApplicationSystemTestCase
  setup do
    @word_chain_walk_step = word_chain_walk_steps(:one)
  end

  test "visiting the index" do
    visit word_chain_walk_steps_url
    assert_selector "h1", text: "Word chain walk steps"
  end

  test "should create word chain walk step" do
    visit word_chain_walk_steps_url
    click_on "New word chain walk step"

    fill_in "Index", with: @word_chain_walk_step.index
    fill_in "Latitude", with: @word_chain_walk_step.latitude
    fill_in "Longitude", with: @word_chain_walk_step.longitude
    fill_in "Memo", with: @word_chain_walk_step.memo
    fill_in "Word", with: @word_chain_walk_step.word
    fill_in "Word chain walk", with: @word_chain_walk_step.word_chain_walk_id
    click_on "Create Word chain walk step"

    assert_text "Word chain walk step was successfully created"
    click_on "Back"
  end

  test "should update Word chain walk step" do
    visit word_chain_walk_step_url(@word_chain_walk_step)
    click_on "Edit this word chain walk step", match: :first

    fill_in "Index", with: @word_chain_walk_step.index
    fill_in "Latitude", with: @word_chain_walk_step.latitude
    fill_in "Longitude", with: @word_chain_walk_step.longitude
    fill_in "Memo", with: @word_chain_walk_step.memo
    fill_in "Word", with: @word_chain_walk_step.word
    fill_in "Word chain walk", with: @word_chain_walk_step.word_chain_walk_id
    click_on "Update Word chain walk step"

    assert_text "Word chain walk step was successfully updated"
    click_on "Back"
  end

  test "should destroy Word chain walk step" do
    visit word_chain_walk_step_url(@word_chain_walk_step)
    accept_confirm { click_on "Destroy this word chain walk step", match: :first }

    assert_text "Word chain walk step was successfully destroyed"
  end
end
