# frozen_string_literal: true

require 'rails_helper'
require 'tempfile'

RSpec.describe 'WordChainWalks', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  scenario '画面遷移せずにStep一覧と次の文字が更新される' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    visit word_chain_walk_path(word_chain_walk)

    expect(page).to have_css('#word_chain_walk_target', text: 'る')
    expect(page).to have_css('#word_chain_walk_steps')

    attach_step_image

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: true
    )

    fill_in '見つけた言葉', with: 'るんば'

    expect do
      click_button '登録する'

      expect(page).to have_current_path(
        word_chain_walk_path(word_chain_walk)
      )

      expect(page).to have_content('るんば')
      expect(page).to have_css('#word_chain_walk_target', text: 'ば')
    end.to change(WordChainWalkStep, :count).by(1)

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: false
    )
  end

  scenario '「ん」で終わる言葉を登録すると、散歩が完了する' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'り')

    visit word_chain_walk_path(word_chain_walk)

    attach_step_image

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: true
    )

    fill_in '見つけた言葉', with: 'りん'

    expect do
      click_button '登録する'

      expect(page).to have_current_path(
        word_chain_walk_completion_path(word_chain_walk)
      )
    end.to change(WordChainWalkStep, :count).by(1)

    expect(word_chain_walk.reload.finished_at).to be_present
  end

  scenario '言葉を入力しないとStepを登録できず、エラーが表示される' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    visit word_chain_walk_path(word_chain_walk)

    attach_step_image

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: true
    )

    expect do
      click_button '登録する'
    end.not_to change(WordChainWalkStep, :count)

    expect(page).to have_content("Word can't be blank")
  end

  scenario 'Stepが0件の散歩でも、最初の1件を一覧に追加できる' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    visit word_chain_walk_path(word_chain_walk)

    expect(page).to have_css('#word_chain_walk_steps')
    expect(page).not_to have_content('るんば')

    attach_step_image

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: true
    )

    fill_in '見つけた言葉', with: 'るんば'

    expect do
      click_button '登録する'

      within '#word_chain_walk_steps' do
        expect(page).to have_content('るんば')
      end
    end.to change(WordChainWalkStep, :count).by(1)
  end

  scenario 'キャンセルするとモーダルが閉じ、入力内容がリセットされる' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    visit word_chain_walk_path(word_chain_walk)

    attach_step_image

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: true
    )

    fill_in '見つけた言葉', with: 'るんば'

    click_button 'キャンセル'

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: false
    )

    word_input =
      find('#word_chain_walk_step_word', visible: :all)

    expect(word_input.value).to eq('')
  end

  scenario '10MBを超える画像を選択するとモーダルを開かない' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    visit word_chain_walk_path(word_chain_walk)

    large_image = create_large_image_file

    attach_file(
      'word_chain_walk_step_image',
      large_image.path,
      make_visible: true
    )

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: false
    )

    expect(
      find('#word_chain_walk_step_image', visible: :all).value
    ).to be_empty
  ensure
    large_image&.close!
  end

  private

  def create_large_image_file
    Tempfile.new(['large_image', '.png']).tap do |file|
      source_image =
        Rails.root.join('spec/fixtures/files/480x320.png')

      file.binmode
      file.write(File.binread(source_image))
      file.truncate(10.megabytes + 1)
      file.rewind
    end
  end

  def attach_step_image
    attach_file(
      'word_chain_walk_step_image',
      Rails.root.join('spec/fixtures/files/480x320.png'),
      make_visible: true
    )
  end
end
