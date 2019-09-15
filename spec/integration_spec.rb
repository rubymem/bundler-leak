require 'spec_helper'

describe "CLI" do
  include Helpers

  let(:command) do
    File.expand_path(File.join(File.dirname(__FILE__),'..','bin','bundler-leak'))
  end

  context "when auditing a bundle with unpatched gems" do
    let(:bundle)    { 'unpatched_gems' }
    let(:directory) { File.join('spec','bundle', bundle) }

    subject do
      Dir.chdir(directory) { sh(command, :fail => true) }
    end

    it "should print a warning" do
      expect(subject).to include("Leaks found!")
    end

    it "should print advisory information for the vulnerable gems" do
      advisory_pattern = /(Name: [^\n]+
Version: \d+.\d+.\d+
URL: https?:\/\/(www\.)?.+
Title: [^\n]*?
Solution: upgrade to (~>|>=) \d+\.\d+\.\d+(\.\d+)?(, (~>|>=) \d+\.\d+\.\d+(\.\d+)?)*[\s\n]*?)/

      expect(subject).to match(advisory_pattern)
      expect(subject).to include("Leaks found!")
    end
  end

  describe "update" do

    let(:update_command) { "#{command} update" }
    let(:bundle)         { 'unpatched_gems' }
    let(:directory)      { File.join('spec','bundle',bundle) }

    subject do
      Dir.chdir(directory) { sh(update_command) }
    end

    context "when advisories update successfully" do
      it "should print status" do
        expect(subject).not_to include("Fail")
        expect(subject).to include("Updating ruby-mem-advisory-db ...\n")
        expect(subject).to include("Updated ruby-mem-advisory-db\n")
        expect(subject.lines.to_a.last).to match(/ruby-mem-advisory-db: \d+ advisories/)
      end
    end

  end

end
