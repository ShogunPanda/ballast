#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Ballast do
  describe "#in_em_thread" do
    it "should yield the block in EM::Synchrony thread" do
      counter = 0
      allow(EM).to receive(:reactor_running?).and_return(true)
      expect(EM::Synchrony).to receive(:defer){|&block| block.call }

      Ballast.in_em_thread { counter = 1 }
      expect(counter).to eq(1)
    end

    it "should call the block normally if EM::Synchrony is not running" do
      counter = 0
      allow(EM).to receive(:reactor_running?).and_return(false)
      expect(EM::Synchrony).not_to receive(:defer)

      Ballast.in_em_thread { counter = 1 }
      expect(counter).to eq(1)
    end

    it "should start a EM:Synchrony on the fly if requested to" do
      counter = 0
      expect(EM).to receive(:reactor_running?).and_return(false)
      expect(EM).to receive(:reactor_running?).and_return(true)
      expect(EM::Synchrony).to receive(:defer){|&block| block.call }
      expect(EM).to receive(:synchrony).and_yield
      expect(EM).to receive(:stop)

      Ballast.in_em_thread(true) { counter = 1 }
      expect(counter).to eq(1)
    end
  end
end