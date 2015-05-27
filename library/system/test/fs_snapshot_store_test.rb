#!/usr/bin/env rspec

require_relative "test_helper"
require "yast2/fs_snapshot_store"

describe Yast2::FsSnapshotStore do
  describe ".save" do
    it "stores snapshot id to file identified by purpose" do
      expect(Yast::SCR).to receive(:Write).with(
        path(".target.string"),
        "/var/lib/YaST2/pre_snapshot_test.id",
        "42"
      ).and_return(true)

      described_class.save("test", 42)
    end

    it "raise exception if writing failed" do
      expect(Yast::SCR).to receive(:Write).with(
        path(".target.string"),
        "/var/lib/YaST2/pre_snapshot_test.id",
        "42"
      ).and_return(nil)

      expect { described_class.save("test", 42) }.to raise_error(/Failed to write/)
    end
  end

  describe ".load" do
    it "loads snapshot id from file identified by purpose" do
      expect(Yast::SCR).to receive(:Read).with(
        path(".target.string"),
        "/var/lib/YaST2/pre_snapshot_test.id"
      ).and_return("42\n")

      expect(described_class.load("test")).to eq 42
    end

    it "raise exception if reading failed" do
      expect(Yast::SCR).to receive(:Read).with(
        path(".target.string"),
        "/var/lib/YaST2/pre_snapshot_test.id"
      ).and_return(nil)

      expect { described_class.load("test") }.to raise_error(/Failed to read/)
    end

    it "raise exception if file content is not number" do
      expect(Yast::SCR).to receive(:Read).with(
        path(".target.string"),
        "/var/lib/YaST2/pre_snapshot_test.id"
      ).and_return("blabla\n")

      expect { described_class.load("test") }.to raise_error(/Failed to read/)
    end
  end

  describe "clean" do
    it "cleans file storing snapshot id" do
      expect(Yast::SCR).to receive(:Execute).with(
        path(".target.remove"),
        "/var/lib/YaST2/pre_snapshot_test.id"
      )

      described_class.clean("test")
    end
  end

  context "in initial stage before SCR switched" do
    it "use path on mounted target system" do
      Yast.import "Installation"
      Yast::Installation.destdir = "/mnt"

      Yast.import "Stage"
      allow(Yast::Stage).to receive(:initial).and_return(true)

      expect(Yast::SCR).to receive(:Execute).with(
        path(".target.remove"),
        "/mnt/var/lib/YaST2/pre_snapshot_test.id"
      )

      described_class.clean("test")
    end
  end
end
