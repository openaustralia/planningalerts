# frozen_string_literal: true

require "spec_helper"

describe ApplicationHelper do
  describe "#meters_in_words" do
    it "converts a distance in metres to simple concise text" do
      expect(helper.meters_in_words(2000.0)).to eq("2 kilometres")
      expect(helper.meters_in_words(500.0)).to eq("500 metres")
    end

    it "rounds distances in km to the nearest 100m" do
      expect(helper.meters_in_words(2345.0)).to eq("2.3 kilometres")
    end

    it "rounds distances in metres to nearest 10m" do
      expect(helper.meters_in_words(923.45)).to eq("920 metres")
    end

    it "rounds distances less than 100 metres to nearest metre" do
      expect(helper.meters_in_words(84.23)).to eq("84 metres")
    end

    it "uses the singular when appropriate" do
      expect(helper.meters_in_words(1000.0)).to eq("1 kilometre")
      expect(helper.meters_in_words(1.0)).to eq("1 metre")
    end
  end

  describe "#significant_figure" do
    it "rounds to two significant figures" do
      expect(helper.significant_figure(0.164, 2)).to eq(0.16)
      expect(helper.significant_figure(1.64, 2)).to eq(1.6)
      expect(helper.significant_figure(16.4, 2)).to eq(16)
      expect(helper.significant_figure(164.0, 2)).to eq(160)
      expect(helper.significant_figure(1640.0, 2)).to eq(1600)
    end

    it "rounds to one significant figure" do
      expect(helper.significant_figure(0.164, 1)).to eq(0.2)
      expect(helper.significant_figure(1.64, 1)).to eq(2)
      expect(helper.significant_figure(16.4, 1)).to eq(20)
      expect(helper.significant_figure(164.0, 1)).to eq(200)
      expect(helper.significant_figure(1640.0, 1)).to eq(2000)
    end

    it "rounds zero without freaking out" do
      expect(helper.significant_figure(0.0, 1)).to eq(0)
    end

    it "rounds negative numbers" do
      expect(helper.significant_figure(-2.34, 2)).to eq(-2.3)
    end
  end
end
