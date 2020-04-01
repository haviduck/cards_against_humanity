module Admin
  class ActivityController < AdminController
    LIMIT = 7.days
    def show
      game_ids = Round.where('updated_at > ?', LIMIT.ago).distinct.pluck(:game_id)

      @games = Game
        .where(id: game_ids)
        .where('max_players > 1')
        .order(created_at: :desc)
        .includes(:rounds, :options)
        .select { |game| game.rounds.many? }
    end
  end
end