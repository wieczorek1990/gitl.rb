#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'shellwords'

# Git looping console program.
class GitLoop
  VERSION = '0.0.3'

  def self.anchor
    dir = File.basename(Dir.pwd)
    return "#{dir}: " unless dir.empty?
  end

  def initialize(arguments)
    return unless arguments.include?('--version')

    puts VERSION
    exit
  end

  def process_commands(input)
    commands = input.split(';').map(&:strip).reject(&:empty?)

    commands.each do |cmd|
      args = Shellwords.shellwords(cmd)

      success = system('git', *args)

      warn "Command '#{cmd}' failed with status #{$CHILD_STATUS.exitstatus}" unless success
    rescue ArgumentError => e
      warn "Syntax error in command '#{cmd}': #{e.message}"
    end
  end

  def trap
    Signal.trap('INT') do
      puts "\nExiting..."
      exit
    end
  end

  def main
    trap
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
