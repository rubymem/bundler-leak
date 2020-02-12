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

require 'yaml'

module Bundler
  module Plumber
    class Advisory < Struct.new(
      :gem,
      :path,
      :id,
      :url,
      :title,
      :date,
      :description,
      :unaffected_versions,
      :patched_versions
    )

      #
      # Loads the advisory from a YAML file.
      #
      # @param [String] path
      #   The path to the advisory YAML file.
      #
      # @return [Advisory]
      #
      # @api semipublic
      #
      def self.load(path)
        id   = File.basename(path).chomp('.yml')
        data = YAML.load_file(path)

        unless data.kind_of?(Hash)
          raise("advisory data in #{path.dump} was not a Hash")
        end

        parse_versions = lambda { |versions|
          Array(versions).map do |version|
            Gem::Requirement.new(*version.split(', '))
          end
        }

        return new(
          data['gem'],
          path,
          id,
          data['url'],
          data['title'],
          data['date'],
          data['description'],
          parse_versions[data['unaffected_versions']],
          parse_versions[data['patched_versions']]
        )
      end

      #
      # Checks whether the version is not affected by the advisory.
      #
      # @param [Gem::Version] version
      #   The version to compare against {#unaffected_versions}.
      #
      # @return [Boolean]
      #   Specifies whether the version is not affected by the advisory.
      #
      # @since 0.2.0
      #
      def unaffected?(version)
        unaffected_versions.any? do |unaffected_version|
          unaffected_version === version
        end
      end

      #
      # Checks whether the version is patched against the advisory.
      #
      # @param [Gem::Version] version
      #   The version to compare against {#patched_versions}.
      #
      # @return [Boolean]
      #   Specifies whether the version is patched against the advisory.
      #
      # @since 0.2.0
      #
      def patched?(version)
        patched_versions.any? do |patched_version|
          patched_version === version
        end
      end

      #
      # Checks whether the version is leaky to the advisory.
      #
      # @param [Gem::Version] version
      #   The version to compare against {#patched_versions}.
      #
      # @return [Boolean]
      #   Specifies whether the version is leaky to the advisory or not.
      #
      def leaky?(version)
        !patched?(version) && !unaffected?(version)
      end

      alias to_s id

    end
  end
end
