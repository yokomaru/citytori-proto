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

    expect_modal_to_be_visible

    fill_in '見つけた言葉', with: 'るんば'

    expect do
      click_button '登録する'

      expect(page).to have_current_path(
        word_chain_walk_path(word_chain_walk)
      )

      expect(page).to have_content('るんば')
      expect(page).to have_css('#word_chain_walk_target', text: 'ば')
    end.to change(WordChainWalkStep, :count).by(1)

    expect_modal_to_be_hidden
  end

  scenario '「ん」で終わる言葉を登録すると、散歩が完了する' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'り')

    visit word_chain_walk_path(word_chain_walk)

    attach_step_image

    expect_modal_to_be_visible

    fill_in '見つけた言葉', with: 'りん'

    expect do
      click_button '登録する'

      expect(page).to have_current_path(
        word_chain_walk_completion_path(word_chain_walk)
      )
    end.to change(WordChainWalkStep, :count).by(1)

    expect(word_chain_walk.reload.finished_at).to be_present
  end

  scenario '言葉を入力しないとStepを登録できず、モーダル内にエラーが表示される' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    visit word_chain_walk_path(word_chain_walk)

    attach_step_image

    expect_modal_to_be_visible

    expect do
      click_button '登録する'

      expect(page).to have_content("Word can't be blank")
    end.not_to change(WordChainWalkStep, :count)

    expect_modal_to_be_visible
  end

  scenario 'Stepが0件の散歩でも、最初の1件を一覧に追加できる' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    visit word_chain_walk_path(word_chain_walk)

    expect(page).to have_css('#word_chain_walk_steps')
    expect(page).not_to have_content('るんば')

    attach_step_image

    expect_modal_to_be_visible

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

    expect_modal_to_be_visible

    fill_in '見つけた言葉', with: 'るんば'

    click_button 'キャンセル'

    expect_modal_to_be_hidden

    word_input =
      find('#word_chain_walk_step_word', visible: :all)

    expect(word_input.value).to eq('')
  end

  scenario 'モーダル背景をクリックするとモーダルが閉じる' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    visit word_chain_walk_path(word_chain_walk)

    attach_step_image

    expect_modal_to_be_visible

    fill_in '見つけた言葉', with: 'るんば'

    modal =
      find("[data-step-form-target='modal']", visible: true)

    page.execute_script('arguments[0].click()', modal)

    expect_modal_to_be_hidden

    word_input =
      find('#word_chain_walk_step_word', visible: :all)

    expect(word_input.value).to eq('')
  end

  scenario '10MBを超える画像を選択するとモーダルを開かない' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    visit word_chain_walk_path(word_chain_walk)

    large_image = create_large_image_file

    page.execute_script(
      'window.alert = function(message) { window._alertMsg = message }'
    )

    attach_file(
      'word_chain_walk_step_image',
      large_image.path,
      make_visible: true
    )

    expect(page.evaluate_script('window._alertMsg'))
      .to eq('画像は10MB以下にしてください。')

    expect_modal_to_be_hidden

    image_input =
      find('#word_chain_walk_step_image', visible: :all)

    expect(image_input.value).to be_empty
  ensure
    large_image&.close!
  end

  scenario '画像を選ぶと、圧縮済みのJPEGがフォーム送信対象になる' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    visit word_chain_walk_path(word_chain_walk)

    attach_step_image

    expect_modal_to_be_visible

    file_info = page.evaluate_script(<<~JAVASCRIPT)
      (() => {
        const input = document.querySelector("#word_chain_walk_step_image")
        const file = input.files[0]

        return {
          name: file.name,
          type: file.type,
          size: file.size
        }
      })()
    JAVASCRIPT

    expect(file_info['name']).to end_with('.jpg')
    expect(file_info['type']).to eq('image/jpeg')
    expect(file_info['size']).to be_positive
  end

  scenario 'モーダルを閉じて再度開くと、前回のエラー表示が消える' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    visit word_chain_walk_path(word_chain_walk)

    attach_step_image

    click_button '登録する'

    within "[data-step-form-target='modal']" do
      expect(page).to have_content("Word can't be blank")
    end

    click_button 'キャンセル'

    expect_modal_to_be_hidden

    attach_step_image

    expect_modal_to_be_visible

    within "[data-step-form-target='modal']" do
      expect(page).not_to have_content("Word can't be blank")
    end
  end

  scenario '最新のStepにだけDestroyボタンが表示される' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    first_step =
      FactoryBot.create(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: 'るす'
      )

    latest_step =
      FactoryBot.create(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: 'すいか'
      )

    visit word_chain_walk_path(word_chain_walk)

    within "#word_chain_walk_step_#{first_step.id}" do
      expect(page).not_to have_button('Destroy')
    end

    within "#word_chain_walk_step_#{latest_step.id}" do
      expect(page).to have_button('Destroy')
    end
  end

  scenario 'Step追加後、Destroyボタンが新しい最新Stepへ移る' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    previous_latest_step =
      FactoryBot.create(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: 'るす'
      )

    visit word_chain_walk_path(word_chain_walk)

    within "#word_chain_walk_step_#{previous_latest_step.id}" do
      expect(page).to have_button('Destroy')
    end

    attach_step_image

    expect_modal_to_be_visible

    fill_in '見つけた言葉', with: 'すいか'

    click_button '登録する'

    expect_modal_to_be_hidden

    new_latest_step =
      WordChainWalkStep
      .where(word_chain_walk: word_chain_walk)
      .order(id: :desc)
      .first

    expect(new_latest_step).not_to eq(previous_latest_step)

    within "#word_chain_walk_step_#{previous_latest_step.id}" do
      expect(page).not_to have_button('Destroy')
    end

    within "#word_chain_walk_step_#{new_latest_step.id}" do
      expect(page).to have_button('Destroy')
    end
  end

  scenario '最新のStepを削除すると、1つ前のStepにDestroyボタンが移る' do
    word_chain_walk =
      FactoryBot.create(:word_chain_walk, start_char: 'る')

    first_step =
      FactoryBot.create(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: 'るす'
      )

    latest_step =
      FactoryBot.create(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: 'すいか'
      )

    visit word_chain_walk_path(word_chain_walk)

    within "#word_chain_walk_step_#{latest_step.id}" do
      accept_confirm('Are you sure?') do
        click_button 'Destroy'
      end
    end

    expect(page).not_to have_css(
      "#word_chain_walk_step_#{latest_step.id}"
    )

    within "#word_chain_walk_step_#{first_step.id}" do
      expect(page).to have_button('Destroy')
    end
  end

  private

  def expect_modal_to_be_visible
    expect(page).to have_css(
      "[data-step-form-target='modal']",
      visible: true
    )
  end

  def expect_modal_to_be_hidden
    expect(page).to have_css(
      "[data-step-form-target='modal']",
      visible: false
    )
  end

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
