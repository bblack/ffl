namespace :db do
  
  desc "Fetch and store espn ids for players of import positions"
  task :fetch_espn_ids => :environment do
    errors = []
    positions = ["QB", "RB", "WR", "TE", "PK"]
    players = Player.where(:position => positions, :espn_id => nil)
    puts "There are #{players.count} players whose espn_ids must be fetched..."
    players.each do |player|
      puts "Fetching for #{player.id}: #{player.first_name} #{player.last_name}"
      begin
        if Player.where(:first_name => player.first_name, :last_name => player.last_name).count > 1
          player.espn_id = nil
          raise StandardError, "Ambiguous player name #{player.first_name} #{player.last_name}"
        end
        player.espn_id = player.try_fetch_espn_id
      rescue Exception => e
        errors << [player.id, e]
      end
      player.save
    end
    puts "All done!"
    if not errors.empty?
      puts "#{errors.count} errors occurred:"
      errors.each do |epair|
        puts "#{epair[0]}: #{epair[1]}"
      end
    end
  end
  
end