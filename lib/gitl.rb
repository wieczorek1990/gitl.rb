# frozen_string_literal: true

# Git loop class
class GitLoop < Object
  def self.version
    File.read('VERSION').chomp
  end

  def self.anchor
    dir = Dir.pwd.split('/').last
    return if dir.nil?

    "#{dir.chomp}: "
  end

  def initialize(arguments)
    return unless arguments.length == 1

    argument = arguments[0]

    return unless argument == '--version'

    puts GitLoop.version
    exit
  end

  def process_commands(input)
    split_commands = input.split(';')
    split_commands.each do |command|
      pid = fork { exec("git #{command}") }
      Process.detach(pid).join
    end
  end

  def main
    Signal.trap('INT') {}

    current_anchor = GitLoop.anchor
    loop do
      print current_anchor unless current_anchor.nil?
      input = gets.chomp
      process_commands(input)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  git_loop = GitLoop.new(ARGV)
  git_loop.main
end
