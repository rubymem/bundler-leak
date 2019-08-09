require 'bundler'
require 'bundler/audit/database'
require 'bundler/lockfile_parser'

require 'ipaddr'
require 'resolv'
require 'set'
require 'uri'

module Bundler
  module Plumber
    class Scanner

      # Represents a gem that is covered by an Advisory
      UnpatchedGem = Struct.new(:gem, :advisory)

      # The advisory database
      #
      # @return [Database]
      attr_reader :database

      # Project root directory
      attr_reader :root

      # The parsed `Gemfile.lock` from the project
      #
      # @return [Bundler::LockfileParser]
      attr_reader :lockfile

      #
      # Initializes a scanner.
      #
      # @param [String] root
      #   The path to the project root.
      #
      # @param [String] gemfile_lock
      #   Alternative name for the `Gemfile.lock` file.
      #
      def initialize(root=Dir.pwd,gemfile_lock='Gemfile.lock')
        @root     = File.expand_path(root)
        @database = Database.new
        @lockfile = LockfileParser.new(
          File.read(File.join(@root,gemfile_lock))
        )
      end

      #
      # Scans the project for issues.
      #
      # @param [Hash] options
      #   Additional options.
      #
      # @option options [Array<String>] :ignore
      #   The advisories to ignore.
      #
      # @yield [result]
      #   The given block will be passed the results of the scan.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      def scan(options={},&block)
        return enum_for(__method__, options) unless block

        ignore = Set[]
        ignore += options[:ignore] if options[:ignore]

        scan_specs(options, &block)

        return self
      end

      #
      # Scans the gem sources in the lockfile.
      #
      # @param [Hash] options
      #   Additional options.
      #
      # @option options [Array<String>] :ignore
      #   The advisories to ignore.
      #
      # @yield [result]
      #   The given block will be passed the results of the scan.
      #
      # @yieldparam [UnpatchedGem] result
      #   A result from the scan.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      # @api semipublic
      #
      # @since 0.4.0
      #
      def scan_specs(options={})
        return enum_for(__method__, options) unless block_given?

        ignore = Set[]
        ignore += options[:ignore] if options[:ignore]

        @lockfile.specs.each do |gem|
          @database.check_gem(gem) do |advisory|

            # TODO this logic should be modified for rubymem
            #unless (ignore.include?(advisory.cve_id) || ignore.include?(advisory.osvdb_id))
            #  yield UnpatchedGem.new(gem,advisory)
            #end
            yield UnpatchedGem.new(gem, advisory)
          end
        end
      end

    end
  end
end
