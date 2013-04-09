tool_name = 'redirect_engine'

require "bundler/gem_tasks"
require File.expand_path("../lib/#{tool_name}/version", __FILE__)

# task :default => :it
task :default => 'ctraut:qwe'

namespace :ctraut do
  desc 'Some experiments by ctraut'
  task :qwe do
    puts 'Hello rake world.'
    puts "Version = #{RedirectEngine::VERSION}"
  end
end

task :ready_for_the_day => [:turn_off_alarm, :groom_myself, :make_coffee, :walk_dog] do
  puts 'Ready for the day!'
end

desc 'make it all'
task :it do
  system "gem build #{tool_name}.gemspec"
  system "gem push #{tool_name}-#{RedirectEngine::VERSION}.gem"
end
