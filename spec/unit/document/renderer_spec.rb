# encoding: utf-8

require "spec_helper"

describe Sie::Document::Renderer, ".add_line" do
  it "replaces input of the wrong encoding with '?'" do
    renderer = Sie::Document::Renderer.new
    renderer.add_line "Hello ☃", 1
    output = renderer.render

    expect(output).to eq "#Hello ? 1\n"
  end
end
