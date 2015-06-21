desc "database... neo..."
load 'neo4j/tasks/neo4j_server.rake'
load 'neo4j/tasks/migration.rake'

desc "Set up and run tests"
task :default => [:test]

desc "Run tests"
task :test do
  sh "bundle exec rspec spec"
end
