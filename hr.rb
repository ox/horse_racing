require "curses"
include Curses
  !
class Horse
  attr_accessor :number, :distance, :chance, :legs, :luck

  def initialize(number)
    self.number = number
    self.distance = 0
    self.chance = (2 + rand * 4 + 1).round(2)
    self.luck = (rand * 15).round(2)
    self.legs = "//"
  end

  def to_s
    "#{legs}#{number}#{legs}"
  end

  def draw_horse(origin)
    setpos(origin[:y], origin[:x])
    addstr(" " * distance)
    addstr(self.to_s)
  end

  def step
    if (rand * 13) > self.chance and (rand * 100) > 35 - self.luck ** 2
      self.distance += 1

      self.legs = (self.legs == "//" ? "\\\\" : "//")
    end
  end
end

horses = []
prerace = true
racing = false

text = {prerace: "Press enter to begin racing!", finish: "Horse %i won!"}

10.times do |x|
  horses[x] = Horse.new(x)
end

if ARGV.first == "test"
  run_test = true

  while run_test
    horses.each do |h|
      h.step
      if h.distance + h.to_s.size >= 100
        run_test = false
      end
    end
  end

  horses.sort_by {|h| -h.distance }.each do |h|
    puts "#{h.number}: #{h.distance}, chance: #{h.chance}, luck: #{h.luck}"
  end
  exit(0)
end

init_screen
begin
  crmode

  while prerace and not racing
    refresh

    horses.each do |h|
      setpos(h.number, 0)
      addstr("#{h.number} [#{h.chance}] #{h.to_s}")
    end

    setpos(lines / 2, (cols - text[:prerace].length) / 2)
    addstr(text[:prerace])

    getch
    prerace = false
    racing = true
    clear
  end

  while racing
    refresh

    horses.each do |h|
      h.step
      h.draw_horse({x: 0, y: h.number})

      if h.distance > 10
        setpos(h.number, 0)
        addstr("[#{h.chance}]")
      end

      if h.distance + h.to_s.size >= 100
        racing = false
      end
    end

    (0...horses.size).each do |x|
      setpos(x, 100)
      addstr("|")
    end

    refresh
    sleep 0.1
  end

  horses.each do |h|
    setpos(h.number, h.distance + h.to_s.size + 1)
    clrtoeol
    addstr("chance: #{h.chance}, luck: #{h.luck}")
  end

  # winning_horse = horses.find {|horse| horse.distance + horse.to_s.size >= 100}
  # clear

  # setpos(lines / 2, (cols - text[:finish].length) / 2)
  # addstr(text[:finish] % winning_horse.number)

  getch
ensure
  close_screen
end
