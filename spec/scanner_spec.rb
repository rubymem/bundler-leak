require 'spec_helper'
require 'bundler/plumber/scanner'

describe Scanner do
  describe "#scan" do
    let(:bundle)    { 'unpatched_gems' }
    let(:directory) { File.join('spec','bundle',bundle) }

    subject { described_class.new(directory) }

    it "should yield results" do
      results = []

      subject.scan { |result| results << result }

      expect(results).not_to be_empty
    end

    context "when not called with a block" do
      it "should return an Enumerator" do
        expect(subject.scan).to be_kind_of(Enumerable)
      end
    end
  end

  context "when auditing a bundle with unpatched gems" do
    let(:bundle)    { 'unpatched_gems' }
    let(:directory) { File.join('spec','bundle',bundle) }
    let(:scanner)  { described_class.new(directory)    }

    subject { scanner.scan.to_a }

    it "should match unpatched gems to their advisories" do
      expect(subject.all? { |result|
        result.advisory.leaky?(result.gem.version)
      }).to be_truthy
    end

    context "when the :ignore option is given" do
      subject { scanner.scan(:ignore => ['celluloid-670']) }

      it "should ignore the specified leaky gems" do
        ids = subject.map { |result| result.advisory.id }

        expect(ids).not_to include('670')
      end
    end
  end
end
