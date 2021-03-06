# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :game, optional: true

  has_many :card_players, -> { order(:position) }, dependent: :destroy
  has_many :cards, through: :card_players
  has_many :submissions, dependent: :destroy

  before_create :set_token

  acts_as_list scope: :game

  validates :name, presence: true

  scope :not_rando, -> { where.not(rando: true) }

  def self.create_rando!
    create!(name: 'Rando', rando: true)
  end

  def to_s
    name
  end

  def play_card(card:, round:)
    transaction do
      # Ensure no existing submission
      submissions.where(round: round).destroy_all

      self.cards -= [card]
      submissions.create!(card: card, round: round)
      round.game.pick_cards(self)
    end
  end

  private

  def set_token
    self.token = SecureRandom.base64
  end
end
