
class Room
  attr_reader :number, :enemy
  attr_accessor :visited

  def initialize(number:)
    @number = number
    @enemy = rand < 0.7 ? Enemy.random : nil
    @gold = rand < 0.4 ? rand(2..10) : 0
    @potion = rand < 0.2
    @visited = false
  end

  def collect_loot(player)
    return if visited

    self.visited = true

    if @gold.positive?
      puts "You find #{@gold} gold."
      player.gold += @gold
    end

    if @potion
      puts "You find a health potion."
      player.potions += 1
    end

    puts "The room appears empty." if @gold.zero? && !@potion && enemy.nil?
  end
end

class Game
  ROOM_COUNT = 6

  def initialize
    @player = create_player
    @rooms = create_rooms
    @current_room_index = 0
    @running = true
  end

  def start
    introduction

    while @running && @player.alive?
      enter_current_room
    end

    finish_game
  end

  private

  def create_player
    print "Enter your adventurer's name: "
    name = gets&.chomp.to_s.strip
    name = "Nameless Adventurer" if name.empty?

    Player.new(name: name)
  end

  def create_rooms
    Array.new(ROOM_COUNT) do |index|
      Room.new(number: index + 1)
    end
  end

  def introduction
    puts
    puts "===================================="
    puts "        THE DUNGEON OF RUBY"
    puts "===================================="
    puts
    puts "#{@player.name} enters the dungeon."
    puts "Find the exit before the dungeon claims you."
  end

  def enter_current_room
    room = @rooms[@current_room_index]

    display_status
    puts
    puts "You enter room #{room.number}."

    room.collect_loot(@player)

    battle(room.enemy) if room.enemy&.alive?

    return unless @player.alive?

    if final_room?
      puts
      puts "You discover a stone staircase leading outside."
      @running = false
    else
      movement_menu
    end
  end

  def display_status
    puts
    puts "------------------------------------"
    puts "Health: #{@player.health}/#{@player.max_health}"
    puts "Gold: #{@player.gold}"
    puts "Potions: #{@player.potions}"
    puts "Room: #{@current_room_index + 1}/#{ROOM_COUNT}"
    puts "------------------------------------"
  end

  def battle(enemy)
    puts
    puts "A #{enemy.name} blocks your path!"

    while enemy.alive? && @player.alive?
      puts
      puts "#{enemy.name}: #{enemy.health} health"
      puts "#{@player.name}: #{@player.health} health"
      puts
      puts "[A]ttack"
      puts "[P]otion"
      puts "[R]un"
      print "> "

      command = gets&.chomp.to_s.downcase

      case command
      when "a", "attack"
        player_attack(enemy)
        enemy_attack(enemy) if enemy.alive?
      when "p", "potion"
        enemy_attack(enemy) if @player.drink_potion
      when "r", "run"
        return if attempt_escape(enemy)
      else
        puts "Unknown command."
      end
    end

    return unless @player.alive?

    puts
    puts "You defeated the #{enemy.name}."

    @player.gold += enemy.gold_reward

    puts "You collect #{enemy.gold_reward} gold."
  end

  def player_attack(enemy)
    damage = @player.attack_damage
    enemy.take_damage(damage)

    puts "You strike the #{enemy.name} for #{damage} damage."
  end

  def enemy_attack(enemy)
    damage = enemy.attack_damage
    @player.take_damage(damage)

    puts "The #{enemy.name} strikes you for #{damage} damage."
  end

  def attempt_escape(enemy)
    if rand < 0.5
      puts "You escape from the #{enemy.name}."

      @current_room_index =
        [@current_room_index - 1, 0].max

      true
    else
      puts "You fail to escape."
      enemy_attack(enemy)
      false
    end
  end

  def movement_menu
    puts
    puts "[N]ext room"

    if @current_room_index.positive?
      puts "[B]ack"
    end

    puts "[Q]uit"
    print "> "

    command = gets&.chomp.to_s.downcase

    case command
    when "n", "next"
      @current_room_index += 1
    when "b", "back"
      if @current_room_index.positive?
        @current_room_index -= 1
      else
        puts "You cannot go back."
      end
    when "q", "quit"
      @running = false
    else
      puts "Unknown command."
    end
  end

  def final_room?
    @current_room_index == ROOM_COUNT - 1
  end

  def finish_game
    puts
    puts "===================================="

    if !@player.alive?
      puts "#{@player.name} died in the dungeon."
    elsif final_room?
      puts "#{@player.name} escaped the dungeon!"
      puts "Gold collected: #{@player.gold}"
    else
      puts "#{@player.name} abandoned the adventure."
    end

    puts "===================================="
  end
end

Game.new.start
