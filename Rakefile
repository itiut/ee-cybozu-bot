def migrate(target = nil)
  require_relative 'db/connection'

  Sequel.extension :migration
  if target
    puts "Migrating to version #{target}"
    Sequel::Migrator.run(DB, 'db/migrations', target: target)
  else
    puts 'Migrating to latest'
    Sequel::Migrator.run(DB, 'db/migrations')
  end
end

namespace :db do
  desc 'Run migrations'
  task :migrate do
    migrate
  end

  desc 'Run down migrations'
  task :down do
    migrate 0
  end

  desc 'Reset migrations'
  task :reset do
    migrate 0
    migrate
  end
end
