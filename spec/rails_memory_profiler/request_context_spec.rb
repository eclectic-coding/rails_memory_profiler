require "rails_helper"

RSpec.describe RailsMemoryProfiler::RequestContext do
  after { described_class.clear }

  describe ".set and .current" do
    it "stores and retrieves context on the current thread" do
      described_class.set(controller: "posts", action: "index", path: "/posts", method: "GET")

      expect(described_class.current).to eq(
        controller: "posts",
        action: "index",
        path: "/posts",
        method: "GET"
      )
    end
  end

  describe ".current" do
    it "returns an empty hash when no context is set" do
      expect(described_class.current).to eq({})
    end
  end

  describe ".clear" do
    it "removes the context from the current thread" do
      described_class.set(controller: "posts", action: "index", path: "/posts", method: "GET")
      described_class.clear

      expect(described_class.current).to eq({})
    end
  end

  describe "thread isolation" do
    it "does not share context between threads" do
      described_class.set(controller: "main", action: "index", path: "/", method: "GET")

      other_context = nil
      Thread.new { other_context = described_class.current }.join

      expect(other_context).to eq({})
    end
  end
end