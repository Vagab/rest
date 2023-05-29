#!/usr/bin/env ruby

require 'optparse'
require 'socket'
require 'fileutils'

system('logger &')

DUMMY_PATH = '/tmp/rest_dummy'
PID_PATH = '/tmp/rest.pid'
FileUtils.touch(DUMMY_PATH) unless File.exist?(DUMMY_PATH)
FileUtils.touch(PID_PATH) unless File.exist?(PID_PATH)

def get_brightness
  `brightness -l`.split.last.to_f
end

def set_brightness(value)
  system("brightness #{value}")
end

def dim_screen(dim_duration, brightness)
  initial_brightness = get_brightness
  current_brightness = initial_brightness
  step = 0.01
  ((initial_brightness - brightness) / step).floor.to_i.times do
    set_brightness(current_brightness -= step)
    sleep step / 100
  end

  set_brightness(brightness)

  sleep(dim_duration)

  ((initial_brightness - brightness) / step).floor.to_i.times do
    set_brightness(current_brightness += step)
    sleep step / 100
  end

  set_brightness(initial_brightness)
end

def parse_time(str)
  if str[-1, 1] == 'm'
    str[0..-2].to_i * 60
  else
    str.to_i
  end
end

def start(options)
  dim_duration = options[:dim_duration] || 30
  sleep_duration = options[:sleep_duration] || 3600
  brightness = options[:brightness] || 0.1
  inactive = options[:inactive] || 15
  run_in_background = options[:run_in_background] || false

  if run_in_background
    pid = fork do
      sleep(sleep_duration)
      run_dimmer(dim_duration, sleep_duration, brightness, inactive)
    end

    if pid
      Process.detach(pid)
      File.write(PID_PATH, pid)
      puts "Dim screen script started in the background with pid #{pid}"
    else
      puts 'Failed to start dim screen script in the background'
    end
  else
    sleep(sleep_duration)
    run_dimmer(dim_duration, sleep_duration, brightness, inactive)
  end
end

def run_dimmer(dim_duration, sleep_duration, brightness, inactive)
  Signal.trap('TERM') do
    FileUtils.rm_f(PID_PATH)
    FileUtils.rm_f(DUMMY_PATH)
    exit
  end

  loop do
    last_modified = File.mtime(DUMMY_PATH)

    if Time.now - last_modified > inactive
      dim_screen(dim_duration, brightness)
      sleep(sleep_duration)
    else
      sleep(1)
    end
  end
end

def stop
  if File.exist?(PID_PATH)
    pid = File.read(PID_PATH).to_i
    Process.kill('TERM', pid)
    FileUtils.rm_f(PID_PATH)
    FileUtils.rm_f(DUMMY_PATH)
    puts 'Dim screen script stopped.'
  else
    puts 'Dim screen script is not running.'
  end
end

options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: rest.rb command [options]'

  opts.on('-dDIM', '--dim=DIM', 'Set dimming duration') do |d|
    d = parse_time(d)
    if d <= 0 || d > 300
      puts 'Dim duration must be a positive integer not exceeding 300 (5 minutes)'
      exit
    end
    options[:dim_duration] = d
  end

  opts.on('-sSLEEP', '--sleep=SLEEP', 'Set sleep duration') do |s|
    s = parse_time(s)
    if s <= 0
      puts 'Sleep duration must be a positive integer'
      exit
    end
    options[:sleep_duration] = s
  end

  opts.on('-bBRIGHTNESS', '--brightness=BRIGHTNESS', 'Set dimming brightness') do |b|
    b = b.to_f
    if b < 0.0 || b > 1.0
      puts 'Brightness must be a float between 0.0 and 1.0'
      exit
    end
    options[:brightness] = b
  end

  opts.on('-iINACTIVE', '--inactive=INACTIVE', 'Set the duration of inactivity before dimming') do |i|
    i = parse_time(i)
    if i <= 0
      puts 'Inactive duration must be a positive integer'
      exit
    end
    options[:inactive] = i
  end

  opts.on('-r', '--run-in-background', 'Run in background') do
    options[:run_in_background] = true
  end

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end

option_parser.order!
command = ARGV.shift
option_parser.order!

case command
when 'run'
  start(options)
when 'stop'
  stop
when 'now'
  stop
  dim_screen(options[:dim_duration] || 30, options[:brightness] || 0.1)
  start(options)
else
  puts "Invalid command. Please use 'run' to start the script and 'stop' to stop it."
  puts option_parser
end
