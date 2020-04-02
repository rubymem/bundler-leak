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

require 'bundler/plumber/scanner'
require 'bundler/plumber/version'

require 'thor'
require 'bundler'
require 'bundler/vendored_thor'

module Bundler
  module Plumber
    class CLI < ::Thor

      default_task :check
      map '--version' => :version

      desc 'check', 'Checks the Gemfile.lock for known memory leaks'
      method_option :quiet, :type => :boolean, :aliases => '-q'
      method_option :verbose, :type => :boolean, :aliases => '-v'
      method_option :ignore, :type => :array, :aliases => '-i'
      method_option :update, :type => :boolean, :aliases => '-u'

      def check
        update if options[:update]

        scanner    = Scanner.new
        leaky = false

        scanner.scan(ignore: options.ignore) do |result|
          leaky = true

          case result
          when Scanner::UnpatchedGem
            print_advisory result.gem, result.advisory
          end
        end

        if leaky
          say "Leaks found!", :red
          exit 1
        else
          say("No leaks found", :green) unless options.quiet?
        end
      end

      desc 'update', 'Updates the ruby-mem-advisory-db'
      method_option :quiet, :type => :boolean, :aliases => '-q'

      def update
        say("Updating ruby-mem-advisory-db ...") unless options.quiet?

        case Database.update!(quiet: options.quiet?)
        when true
          say("Updated ruby-mem-advisory-db", :green) unless options.quiet?
        when false
          say "Failed updating ruby-mem-advisory-db!", :red
          exit 1
        when nil
          say "Skipping update", :yellow
        end

        unless options.quiet?
          puts("ruby-mem-advisory-db: #{Database.new.size} advisories")
        end
      end

      desc 'version', 'Prints the bundler-leak version'
      def version
        database = Database.new

        puts "#{File.basename($0)} #{VERSION} (advisories: #{database.size})"
      end

      protected

      def say(message="", color=nil)
        color = nil unless $stdout.tty?
        super(message.to_s, color)
      end

      def print_warning(message)
        say message, :yellow
      end

      def print_advisory(gem, advisory)
        say "Name: ", :red
        say gem.name

        say "Version: ", :red
        say gem.version

        say "URL: ", :red
        say advisory.url

        if options.verbose?
          say "Description:", :red
          say

          print_wrapped advisory.description, :indent => 2
          say
        else

          say "Title: ", :red
          say advisory.title
        end

        unless advisory.patched_versions.empty?
          say "Solution: upgrade to ", :red
          say advisory.patched_versions.join(', ')
        else
          say "Solution: ", :red
          say "remove or disable this gem until a patch is available!", [:red, :bold]
        end

        say
      end

    end
  end
end
