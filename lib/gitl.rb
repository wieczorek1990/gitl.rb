#!/usr/bin/env ruby
# frozen_string_literal: true

require 'shellwords'

class GitLoop
  VERSION = "0.0.3"

  def self.anchor
    dir = File.basename(Dir.pwd)
    return "#{dir}: " unless dir.empty?
  end

  def initialize(arguments)
    if arguments.include?('--version')
      puts VERSION
      exit
    end
  end

  def process_commands(input)
    commands = input.split(';').map(&:strip).reject(&:empty?)

    commands.each do |cmd|
      begin
        # 2. Use Shellwords to parse arguments correctly
        # This handles "file with spaces.txt" and escaped quotes
        args = Shellwords.shellwords(cmd)

        # Execute git with the parsed array
        success = system("git", *args)

        unless success
          warn "Command '#{cmd}' failed with status #{$?.exitstatus}"
        end
      rescue ArgumentError => e
        # Handle cases where shell parsing fails (e.g., unclosed quotes)
        warn "Syntax error in command '#{cmd}': #{e.message}"
      end
    end
  end

  def main
    Signal.trap('INT') {
      puts "\nExiting..."
      exit
    }

    anchor = GitLoop.anchor
    loop do
      print anchor if anchor

      input = gets&.chomp
      break if input.nil? || input.strip == 'quit'

      process_commands(input)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  git_loop = GitLoop.new(ARGV)
  git_loop.main
end
