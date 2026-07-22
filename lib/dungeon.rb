#!/usr/bin/env ruby
# frozen_string_literal: true

class Character
  attr_reader :name
  attr_accessor :health

  def initialize(name:, health:, attack:)
    @name = name
    @health = health
    @attack = attack
  end

end
