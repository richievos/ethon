require 'spec_helper'

describe Ethon::Multi do
  describe "curl object cleanup" do
    describe "its handle" do
      it "sets up a finalizer when it's touched" do
        multi = Ethon::Multi.new
        ObjectSpace.should_receive(:define_finalizer)
        multi.handle
      end

      describe ".finalizer" do
        it "calls multi_cleanup" do
          handle = stub
          Ethon::Curl.should_receive(:multi_cleanup).with(handle).at_least(1)
          Ethon::Multi.build_multi_handle_finalizer(handle).call
        end
      end
    end
  end

  describe ".new" do
    it "inits curl" do
      Ethon::Curl.should_receive(:init)
      Ethon::Multi.new
    end

    context "when options not empty" do
      context "when pipelining is set" do
        let(:options) { { :pipelining => true } }

        it "sets pipelining" do
          Ethon::Multi.any_instance.should_receive(:pipelining=).with(true)
          Ethon::Multi.new(options)
        end
      end
    end
  end
end
