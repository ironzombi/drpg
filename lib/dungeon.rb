#!/usr/bin/env ruby
# frozen_string_literal: true

class Character
  attr_reader :name, :max_health
  attr_accessor :health

  def initialize(name:, health:, attack:)
    @name = name
    @health = health
    @max_health = max_health
    @attack = attack
  end

  def alive?
    health.positive?
  end

  def attack_damage
    rand(1..@attack)
  end

  def take_damage(amount)
    self.health = [health - amount, 0].max
  end

end

class Player < Character
  attr_accessor :gold, :potions

  def initialize(name:)
    super(
      name: name,
      health: 30,
      attack: 8
    )

    @gold = 0
    @potions = 2
  end

  def drink_potion
    if potions.zero?
      puts "You do not have any"
      return false
    end

    healing = rand(6..12)
    self.health = [health + healing, max_health].min
    self.potions -= 1
    puts "You drink a potion and recover #{healing} health"
    true
  end
end
