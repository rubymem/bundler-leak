require 'spec_helper'
require 'bundler/plumber/database'
require 'bundler/plumber/advisory'

describe Bundler::Plumber::Advisory do
  let(:root) { Bundler::Plumber::Database::VENDORED_PATH }
  let(:gem)  { 'therubyracer' }
  let(:id)   { '336' }
  let(:path) { File.join(root,'gems',gem,"#{id}.yml") }
  let(:an_unaffected_version) do
    Bundler::Plumber::Advisory.load(path).unaffected_versions.map { |version_rule|
      # For all the rules, get the individual constraints out and see if we
      # can find a suitable one...
      version_rule.requirements.select { |(constraint, gem_version)|
        # We only want constraints where the version number specified is
        # one of the unaffected version.  I.E. we don't want ">", "<", or if
        # such a thing exists, "!=" constraints.
        ['~>', '>=', '=', '<='].include?(constraint)
      }.map { |(constraint, gem_version)|
        # Fetch just the version component, which is a Gem::Version,
        # and extract the string representation of the version.
        gem_version.version
      }
    }.flatten.first
  end

  subject { described_class.load(path) }

  describe "load" do
    let(:data) { YAML.load_file(path) }

    describe '#id' do
      subject { super().id }
      it { is_expected.to eq(id) }
    end

    describe '#url' do
      subject { super().url }
      it { is_expected.to eq(data['url']) }
    end

    describe '#title' do
      subject { super().title }
      it { is_expected.to eq(data['title']) }
    end

    describe '#date' do
      subject { super().date }
      it { is_expected.to eq(data['date']) }
    end

    describe '#description' do
      subject { super().description }
      it { is_expected.to eq(data['description']) }
    end

    context "YAML data not representing a hash" do
      it "should raise an exception" do
        path = File.expand_path('../fixtures/not_a_hash.yml', __FILE__)
        expect {
          Advisory.load(path)
        }.to raise_exception("advisory data in #{path.dump} was not a Hash")
      end
    end

    describe "#patched_versions" do
      subject { described_class.load(path).patched_versions }

      it "should all be Gem::Requirement objects" do
        expect(subject.all? { |version|
          expect(version).to be_kind_of(Gem::Requirement)
        }).to be_truthy
      end

      it "should parse the versions" do
        expect(subject.map(&:to_s)).to eq(data['patched_versions'])
      end
    end
  end


  describe "#unaffected?" do
    context "when passed a version that matches one unaffected version" do
      let(:version) { Gem::Version.new(an_unaffected_version) }

      it "should return true" do
        expect(subject.unaffected?(version)).to be_truthy
      end
    end

    context "when passed a version that matches no unaffected version" do
      let(:version) { Gem::Version.new('3.0.9') }

      it "should return false" do
        expect(subject.unaffected?(version)).to be_falsey
      end
    end
  end

  describe "#patched?" do
    context "when passed a version that matches one patched version" do
      let(:version) { Gem::Version.new('0.12.4') }

      it "should return true", doku: true do
        expect(subject.patched?(version)).to be_truthy
      end
    end

    context "when passed a version that matches no patched version" do
      let(:version) { Gem::Version.new('2.9.0') }

      it "should return false" do
        expect(subject.patched?(version)).to be_falsey
      end
    end
  end

  describe "#leaky?" do
    context "when passed a version that matches one patched version" do
      let(:version) { Gem::Version.new('0.12.4') }

      it "should return false" do
        expect(subject.leaky?(version)).to be_falsey
      end
    end

    context "when passed a version that matches no patched version" do
      let(:version) { Gem::Version.new('2.9.0') }

      it "should return true" do
        expect(subject.leaky?(version)).to be_truthy
      end

      context "when unaffected_versions is not empty" do
        subject { described_class.load(path) }

        context "when passed a version that matches one unaffected version" do
          let(:version) { Gem::Version.new(an_unaffected_version) }

          it "should return false" do
            expect(subject.leaky?(version)).to be_falsey
          end
        end

        context "when passed a version that matches no unaffected version" do
          let(:version) { Gem::Version.new('1.2.3') }

          it "should return true" do
            expect(subject.leaky?(version)).to be_truthy
          end
        end
      end
    end
  end
end
