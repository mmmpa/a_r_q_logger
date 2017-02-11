DATABASE_NAME = :a_r_q_logger_test_database
DATABASE_CONFIGURATION_BASE = {
  adapter: :mysql2,
  host: :localhost,
  username: ENV['MYSQL_USER_NAME'],
  password: ENV['MYSQL_USER_PASSWORD'],
}

class DummyCreator < ActiveRecord::Migration
  class << self
    def up
      create_table "test_child_models", force: :cascade do |t|
        t.integer  "test_model_id"
        t.string   "name"
        t.datetime "created_at",    null: false
        t.datetime "updated_at",    null: false
      end

      create_table "test_models", force: :cascade do |t|
        t.string   "name"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
      end
    rescue
      nil
    end

    def down
      drop_table(:test_child_models)
      drop_table(:test_models)
    rescue
      nil
    end
  end
end

RSpec.configure do |config|
  config.before :suite do
    ActiveRecord::Base.establish_connection(DATABASE_CONFIGURATION_BASE)
    begin
      ActiveRecord::Base.connection.create_database(DATABASE_NAME)
    rescue ActiveRecord::StatementInvalid => e
      # yay
    end

    ActiveRecord::Base.establish_connection(DATABASE_CONFIGURATION_BASE.merge(
      database: DATABASE_NAME,
    ))

    DummyCreator.up rescue nil
  end

  config.after :suite do
    DummyCreator.down
  end
end
