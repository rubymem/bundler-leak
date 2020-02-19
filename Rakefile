# encoding: utf-8

require 'rubygems'

begin
  require 'bundler/setup'
rescue LoadError => e
  abort e.message
end

require 'rake'
require 'time'

require 'rubygems/tasks'
Gem::Tasks.new

namespace :db do
  desc 'Updates data/ruby-mem-advisory-db'
  task :update do
    timestamp = nil

    chdir 'data/ruby-mem-advisory-db' do
      sh 'git', 'pull', 'origin', 'master'

      File.open('../ruby-mem-advisory-db.ts','w') do |file|
        file.write Time.parse(`git log --pretty="%cd" -1`).utc
      end
    end

    sh 'git', 'commit', 'data/ruby-mem-advisory-db',
                        'data/ruby-mem-advisory-db.ts',
                        '-m', 'Updated ruby-mem-advisory-db'
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

namespace :spec do
  task :bundle do
    root = 'spec/bundle'

    %w[unpatched_gems].each do |bundle|
      chdir(File.join(root,bundle)) do
        sh "unset BUNDLE_BIN_PATH BUNDLE_GEMFILE RUBYOPT && bundle config set --local path '../../../vendor/bundle' && bundle install"
      end
    end
  end
end
task :spec => 'spec:bundle'

task :test    => :spec
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
task :doc => :yard
