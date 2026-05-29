require "application_system_test_case"

class WordChainWalksTest < ApplicationSystemTestCase
  setup do
    @word_chain_walk = word_chain_walks(:one)
  end

  test "visiting the index" do
    visit word_chain_walks_url
    assert_selector "h1", text: "Word chain walks"
  end

  test "should create word chain walk" do
    visit word_chain_walks_url
    click_on "New word chain walk"

    fill_in "Finished at", with: @word_chain_walk.finished_at
    fill_in "Start char", with: @word_chain_walk.start_char
    fill_in "Started at", with: @word_chain_walk.started_at
    click_on "Create Word chain walk"

    assert_text "Word chain walk was successfully created"
    click_on "Back"
  end

  test "should update Word chain walk" do
    visit word_chain_walk_url(@word_chain_walk)
    click_on "Edit this word chain walk", match: :first

    fill_in "Finished at", with: @word_chain_walk.finished_at
    fill_in "Start char", with: @word_chain_walk.start_char
    fill_in "Started at", with: @word_chain_walk.started_at
    click_on "Update Word chain walk"

    assert_text "Word chain walk was successfully updated"
    click_on "Back"
  end

  test "should destroy Word chain walk" do
    visit word_chain_walk_url(@word_chain_walk)
    accept_confirm { click_on "Destroy this word chain walk", match: :first }

    assert_text "Word chain walk was successfully destroyed"
  end
end
