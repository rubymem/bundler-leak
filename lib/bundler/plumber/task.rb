#
# Copyright (c) 2019 Ombulabs (hello at ombulabs.com)
# Copyright (c) 2013-2016 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# bundler-leak is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# bundler-leak is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with bundler-leak.  If not, see <http://www.gnu.org/licenses/>.
#

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
