namespace :db do
  desc "Convert move2 to pvc"
  task :m2_to_pvc => :environment do
    ActiveRecord::Base.transaction do
      Move2.where('new_pv is not null').find_each do |m|
        pvc = PlayerValueChange.new(
          :player_id => m.player_id,
          :new_value => m.new_pv,
          :first_year => m.season || 2012,
          :last_year => m.final_year || [(m.new_pv/15).ceil, 1].max,
          :team_id => m.new_team_id,
          :comment => "Imported from Move2 at #{Time.now.to_s}",
          :created_at => m.created_at,
          :updated_at => m.updated_at
          )
        pvc.save!
      end
    end
  end
end