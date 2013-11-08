=begin database.yml
  test:
    adapter: sqlite3
    database: ":memory:"
    verbosity: quiet
=end

def in_memory_database?
  Rails.env == "test" and
    # ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLiteAdapter ||
    ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLite3Adapter and
    Rails.configuration.database_configuration['test']['database'] == ':memory:'
end

if in_memory_database?
  puts "create sqlite db in memory database"
  #Rails.configuration.active_record.migration = :page_load
  #Rails.configuration.active_record.skip_migration_errors = true
  # ActiveRecord::Schema.verbose = false
  load "#{Rails.root}/db/schema.rb"
  # ActiveRecord::Migrator.up("#{Rails.root}/db/migrate")
end

