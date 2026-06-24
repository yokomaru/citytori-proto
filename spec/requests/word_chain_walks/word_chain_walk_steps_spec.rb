# frozen_string_literal: true

require 'rails_helper'
require 'tempfile'

RSpec.describe 'WordChainWalks::WordChainWalkSteps', type: :request do
  let(:word_chain_walk) { FactoryBot.create(:word_chain_walk, start_char: 'り') }
  describe 'POST /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps' do
    context 'ステップを登録する場合' do
      it '成功すること' do
        expect do
          post word_chain_walk_word_chain_walk_steps_path(word_chain_walk), params: {
            word_chain_walk_step: {
              word: 'りんご',
              image: fixture_file_upload(Rails.root.join('spec/fixtures/files/480x320.png'))
            }
          }
        end.to change(WordChainWalkStep, :count).by(1)

        expect(response).to redirect_to(word_chain_walk_path(word_chain_walk))
      end

      it '失敗すること' do
        expect do
          post word_chain_walk_word_chain_walk_steps_path(word_chain_walk), params: {
            word_chain_walk_step: {
              word: nil,
              image: fixture_file_upload(Rails.root.join('spec/fixtures/files/480x320.png'))
            }
          }
        end.not_to change(WordChainWalkStep, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'んで終わる単語を登録したら散歩が終了すること' do
        expect do
          post word_chain_walk_word_chain_walk_steps_path(word_chain_walk), params: {
            word_chain_walk_step: {
              word: 'りん',
              image: fixture_file_upload(Rails.root.join('spec/fixtures/files/480x320.png'))
            }
          }
        end.to change(WordChainWalkStep, :count).by(1)

        expect(word_chain_walk.reload.finished?).to be true
        expect(word_chain_walk.finished_at).to be_present
        expect(response).to redirect_to(word_chain_walk_completion_path(word_chain_walk))
      end
    end
  end

  describe 'DELETE /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps/latest' do
    context 'ステップが存在する場合' do
      it 'ステップが削除されること' do
        old_step = FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: 'りんご')
        latest_step = FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk,
                                                                            word: 'ごりら')

        expect do
          delete latest_word_chain_walk_word_chain_walk_steps_path(word_chain_walk)
        end.to change(WordChainWalkStep, :count).by(-1)

        expect(WordChainWalkStep.exists?(old_step.id)).to be true
        expect(WordChainWalkStep.exists?(latest_step.id)).to be false
        expect(response).to redirect_to(word_chain_walk_path(word_chain_walk))
      end
    end

    context 'ステップが存在しない場合' do
      it 'ステップが削除されないこと' do
        expect do
          delete latest_word_chain_walk_word_chain_walk_steps_path(word_chain_walk)
        end.not_to change(WordChainWalkStep, :count)

        expect(response).to redirect_to(word_chain_walk_path(word_chain_walk))
      end
    end
  end

  describe 'image size validation' do
    it '10MB以下の画像は有効である' do
      step = FactoryBot.build(:word_chain_walk_step)

      step.image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/480x320.png')),
        filename: '480x320.png',
        content_type: 'image/png'
      )

      expect(step).to be_valid
    end

    it '10MBを超える画像は無効である' do
      file = Tempfile.new(['large_image', '.png'])
      file.truncate(10.megabytes + 1)
      file.rewind

      step = FactoryBot.build(:word_chain_walk_step)

      step.image.attach(
        io: file,
        filename: 'large_image.png',
        content_type: 'image/png'
      )

      expect(step).to be_invalid
      expect(step.errors[:image]).to include('は10MB以下にしてください')
    ensure
      file&.close!
    end
  end
end
