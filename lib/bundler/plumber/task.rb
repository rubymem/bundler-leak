require 'rake/tasklib'

module Bundler
  module Plumber
    class Task < Rake::TaskLib
      #
      # Initializes the task.
      #
      def initialize
        define
      end

      protected

      #
      # Defines the `bundle:leak` task.
      #
      def define
        namespace :bundle do
          desc 'Updates the ruby-mem-advisory-db then runs bundle-leak'
          task :leak do
            require 'bundler/plumber/cli'
            %w(update check).each do |command|
              Bundler::Plumber::CLI.start [command]
            end
          end
        end
      end
    end
  end
end
