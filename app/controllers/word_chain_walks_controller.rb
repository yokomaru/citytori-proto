class WordChainWalksController < ApplicationController
  before_action :set_word_chain_walk, only: %i[ show destroy ]

  # GET /word_chain_walks or /word_chain_walks.json
  def index
    @active_word_chain_walks = WordChainWalk.preload(:word_chain_walk_steps).order(id: :desc).active
    @completed_word_chain_walks = WordChainWalk.preload(:word_chain_walk_steps).order(id: :desc).finished
  end

  # GET /word_chain_walks/1 or /word_chain_walks/1.json
  def show
    @word_chain_walk = WordChainWalk.find(params[:id])
    @word_chain_walk_steps = @word_chain_walk.word_chain_walk_steps.with_attached_image.order(id: :desc)
    @locations = @word_chain_walk.word_chain_walk_steps.where.not(latitude: nil, longitude: nil).order(id: :desc).pluck(:latitude, :longitude)
  end

  # POST /word_chain_walks or /word_chain_walks.json
  def create
    @word_chain_walk = WordChainWalk.new

    if @word_chain_walk.save
      redirect_to @word_chain_walk, notice: "Word chain walk was successfully created."
    else
      @active_word_chain_walks = WordChainWalk.preload(:word_chain_walk_steps).order(id: :desc).active
      @completed_word_chain_walks = WordChainWalk.preload(:word_chain_walk_steps).order(id: :desc).finished
      render :index, status: :unprocessable_content
    end
  end

  # DELETE /word_chain_walks/1 or /word_chain_walks/1.json
  def destroy
    @word_chain_walk.destroy!

    redirect_to word_chain_walks_path, notice: "Word chain walk was successfully destroyed.", status: :see_other
  end

  private
    def set_word_chain_walk
      @word_chain_walk = WordChainWalk.find(params[:id])
    end
end
