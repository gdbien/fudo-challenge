MIGRATIONS_PATH = 'db/migrate'.freeze

namespace :db do
  desc 'Run migrations'
  task :migrate, [:version] do |_, args|
    puts 'Running migrations'
    require 'sequel/core'
    require 'logger'
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel.connect(ENV.fetch('DATABASE_URL'), loggers: [Logger.new($stdout)]) do |db|
      Sequel::Migrator.run(db, MIGRATIONS_PATH, target: version)
    end
  end
end

desc 'Run rubocop'
task :rubocop do
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.fail_on_error = false
  end
end

desc 'Run tests'
task :test do
  puts 'Running tests'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  Rake::Task['spec'].execute
end

task default: ['db:migrate', :rubocop, :test]
