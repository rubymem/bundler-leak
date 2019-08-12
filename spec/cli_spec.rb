require 'spec_helper'
require 'bundler/plumber/cli'

describe Bundler::Plumber::CLI do
  describe "#update" do
    context "not --quiet (the default)" do
      context "when update succeeds" do

        before { expect(Bundler::Plumber::Database).to receive(:update!).and_return(true) }

        it "prints updated message" do
          expect { subject.update }.to output(/Updated ruby-mem-advisory-db/).to_stdout
        end

        it "prints total advisory count" do
          database = double
          expect(database).to receive(:size).and_return(1234)
          expect(Bundler::Plumber::Database).to receive(:new).and_return(database)

          expect { subject.update }.to output(/ruby-mem-advisory-db: 1234 advisories/).to_stdout
        end
      end

      context "when update fails" do

        before { expect(Bundler::Plumber::Database).to receive(:update!).and_return(false) }

        it "prints failure message" do
          expect do
            begin
              subject.update
            rescue SystemExit
            end
          end.to output(/Failed updating ruby-mem-advisory-db!/).to_stdout
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
      before do
        allow(subject).to receive(:options).and_return(double("Options", quiet?: true))
      end

      context "when update succeeds" do

        before do
          expect(Bundler::Plumber::Database).to(
            receive(:update!).with(quiet: true).and_return(true)
          )
        end

        it "does not print any output" do
          expect { subject.update }.to_not output.to_stdout
        end
      end

      context "when update fails" do

        before do
          expect(Bundler::Plumber::Database).to(
            receive(:update!).with(quiet: true).and_return(false)
          )
        end

        it "prints failure message" do
          expect do
            begin
              subject.update
            rescue SystemExit
            end
          end.to output(/Failed updating ruby-mem-advisory-db!/).to_stdout
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
  end
end
