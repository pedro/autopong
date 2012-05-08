require "rake/testtask"
Dir["./lib/tasks/*.rake"].sort.each { |ext| load ext }

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

task :default => :test
