require 'spec_helper'
require 'bundler/plumber/cli'

describe Bundler::Plumber::CLI do
  describe "#update" do
    context "not --quiet (the default)" do
      context "when update succeeds" do
        before { allow(Bundler::Plumber::Database).to receive(:update!).and_return(true) }

        it "prints updated message" do
          allow(subject).to(
            receive(:say)
          )

          subject.update

          expect(subject).to(
            have_received(:say).with("Updated ruby-mem-advisory-db", :green)
          )
        end

        it "prints total advisory count" do
          database = double
          allow(database).to receive(:size).and_return(1234)
          allow(Bundler::Plumber::Database).to receive(:new).and_return(database)

          allow(subject).to(
            receive(:say)
          )

          subject.update

          expect(subject).to(
            have_received(:say).with("ruby-mem-advisory-db: 1234 advisories", :green)
          )
        end
      end

      context "when update fails" do
        before { allow(Bundler::Plumber::Database).to receive(:update!).and_return(false) }

        it "prints failure message" do
          allow(subject).to(receive(:say))
          allow(subject).to(receive(:exit))

          subject.update

          expect(subject).to(
            have_received(:say).with("Failed updating ruby-mem-advisory-db!", :red)
          )
        end

        it "exits with error status code" do
          expect {
            # Capture output of `update` only to keep spec output clean.
            # The test regarding specific output is above.
            expect { subject.update }.to output.to_stdout
          }.to raise_error(SystemExit) do |error|
            expect(error.success?).to eq(false)
            expect(error.status).to eq(1)
          end
        end

      end
    end

    context "--quiet" do
      subject do
        Bundler::Plumber::CLI.new([], quiet: true)
      end

      context "when update succeeds" do

        before do
          allow(Bundler::Plumber::Database).to(
            receive(:update!).with(quiet: true).and_return(true)
          )
        end

        it "does not print any output" do
          expect { subject.update }.to_not output.to_stdout
        end
      end

      context "when update fails" do
        before do
          allow(Bundler::Plumber::Database).to(
            receive(:update!).with(quiet: true).and_return(false)
          )
          allow(subject).to receive(:exit)
        end

        it "prints failure message" do
          allow(subject).to(
            receive(:say)
          )

          subject.update

          expect(subject).to(
            have_received(:say).with("Failed updating ruby-mem-advisory-db!", :red)
          )
        end

        it "exits with error status code" do
          allow(subject).to receive(:exit)

          subject.update

          expect(subject).to have_received(:exit).with(1)
        end
      end
    end
  end
end
