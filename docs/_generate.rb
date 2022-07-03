#!/usr/bin/env ruby

require "erb"
require "fileutils"

def usage
  puts "Usage: $0 [-h]"
  exit 1
end

usage if ARGV[1] == "-h"

directory = "docs"

Dir.glob("#{directory}/**/*.erb").each do |source_file|
  output_dir = File
    .dirname(source_file)
    .gsub(%r{(?:docs|env)}, "")

  output_file = File.join(
      output_dir,
      File.basename(source_file)
    )
    .gsub(%r{^/}, "")
    .gsub(/\.erb$/, "")

  template = File.read(source_file)
  renderer = ERB.new(template, nil, "-")

  File.write(output_file, renderer.result())
end
