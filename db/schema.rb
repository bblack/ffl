# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141018051417) do

  create_table "contracts", :force => true do |t|
    t.integer  "team_id"
    t.integer  "player_id"
    t.integer  "first_year"
    t.integer  "length"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "nixed_at"
    t.string   "nix_message"
    t.datetime "started_at"
    t.text     "started_msg"
  end

  create_table "espn_roster_spots", :force => true do |t|
    t.integer  "espn_player_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "espn_stats", :force => true do |t|
    t.integer  "player_id"
    t.integer  "league_id"
    t.integer  "week"
    t.integer  "season"
    t.string   "stats"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leagues", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "salary_cap"
    t.string   "espn_id"
    t.integer  "season"
  end

  create_table "move2s", :force => true do |t|
    t.integer  "player_id"
    t.integer  "old_team_id"
    t.string   "type"
    t.integer  "new_team_id"
    t.integer  "new_pv"
    t.text     "comment"
    t.integer  "final_year"
    t.integer  "move2_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "league_id"
    t.integer  "season"
  end

  create_table "moves", :force => true do |t|
    t.integer  "transaction_id"
    t.integer  "old_contract_id"
    t.integer  "new_contract_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "player_value_changes", :force => true do |t|
    t.integer  "player_id"
    t.integer  "new_value"
    t.integer  "first_year"
    t.integer  "last_year"
    t.integer  "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "league_id"
  end

  create_table "players", :force => true do |t|
    t.integer  "mfl_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nfl_team"
    t.string   "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "espn_id"
  end

  create_table "rfa_bids", :force => true do |t|
    t.integer  "rfa_period_id"
    t.integer  "team_id"
    t.integer  "player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "value"
  end

  create_table "rfa_decision_periods", :force => true do |t|
    t.integer  "rfa_period_id"
    t.datetime "open_date"
    t.datetime "close_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rfa_decisions", :force => true do |t|
    t.integer  "rfa_decision_period_id"
    t.integer  "player_id"
    t.integer  "team_id"
    t.boolean  "keep"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "made_by_redbutton"
  end

  create_table "rfa_periods", :force => true do |t|
    t.integer  "final_year"
    t.datetime "open_date"
    t.datetime "close_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "league_id"
    t.boolean  "redbuttoned"
  end

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "league_id"
    t.integer  "owner_id"
    t.string   "espn_id"
    t.datetime "espn_roster_last_updated"
  end

  create_table "transaction_comments", :force => true do |t|
    t.integer  "transaction_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_on"
    t.integer  "user_id"
    t.integer  "league_id"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "pw_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "god_mode"
  end

end
