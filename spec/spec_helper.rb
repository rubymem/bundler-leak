require 'simplecov'
SimpleCov.start

require 'rspec'
require 'bundler/plumber/version'
require 'bundler/plumber/database'

module Helpers
  def sh(command, options={})
    with_unbundled_env do
      result = `#{command} 2>&1`
      raise "FAILED #{command}\n#{result}" if $?.success? == !!options[:fail]
      result
    end
  end

  def decolorize(string)
    string.gsub(/\e\[\d+m/, "")
  end

  def mocked_user_path
    File.expand_path('../../tmp/ruby-mem-advisory-db', __FILE__)
  end

  def expect_update_to_clone_repo!(quiet: false)
    with = ['git', 'clone']
    with << '--quiet' if quiet
    with << Bundler::Plumber::Database::VENDORED_PATH << mocked_user_path

    expect(Bundler::Plumber::Database).
      to receive(:system).
      with(*with).
      and_call_original
  end

  def expect_update_to_update_repo!(quiet: false)
    with = 'git fetch --all; git reset --hard origin/master'
    with << " --quiet" if quiet

    expect(Bundler::Plumber::Database).
      to receive(:system).
      with(with).
      and_call_original
  end

  def fake_a_commit_in_the_user_repo
    Dir.chdir(mocked_user_path) do
      system 'git', 'commit', '--allow-empty', '-m', 'Dummy commit.'
    end
  end

  def roll_user_repo_back(num_commits)
    Dir.chdir(mocked_user_path) do
      system 'git', 'reset', '--hard', "HEAD~#{num_commits}"
    end
  end

  private

  def with_unbundled_env
    bundler_ver = Gem::Version.new(Bundler::VERSION)
    if bundler_ver < Gem::Version.new('2.1.0')
      Bundler.with_clean_env { yield }
    else
      Bundler.with_unbundled_env { yield }
    end
  end
end

include Bundler::Plumber

RSpec.configure do |config|
  include Helpers

  config.before(:each) do
    stub_const("Bundler::Plumber::Database::URL", Bundler::Plumber::Database::VENDORED_PATH)
    stub_const("Bundler::Plumber::Database::USER_PATH", mocked_user_path)
    FileUtils.rm_rf(mocked_user_path) if File.exist?(mocked_user_path)
  end
end
