require 'pry'

# https://github.com/edrans/toy-robot-challenge

Vector = Struct.new(:x, :y)
class Vector
    def +(vector)
        Vector.new(x + vector.x, y + vector.y)
    end
end

module CompassDirection
    NORTH = 0
    EAST = 1
    SOUTH = 2
    WEST = 3

    DIRECTIONS = [
        NORTH,
        EAST,
        SOUTH,
        WEST
    ]

    DIRECTIONS_TEXT = [
        "NORTH",
        "EAST",
        "SOUTH",
        "WEST"
    ]

    def self.turn_from_direction(currently_facing, turn_left = true)
        (DIRECTIONS.index(currently_facing) + DIRECTIONS.length + (turn_left ? -1 : 1)) % DIRECTIONS.length
    end

    def self.get_index_from_direction_text(direction_text)
        DIRECTIONS_TEXT.index(direction_text)
    end

    def self.get_direction_text_from_index(index)
        DIRECTIONS_TEXT[index]
    end
end

module DeltaMovements
    NORTH = Vector.new(0, 1)
    EAST = Vector.new(1, 0)
    SOUTH = Vector.new(0, -1)
    WEST = Vector.new(-1, 0)

    def self.get_delta_movement_in_direction(facing)
        return NORTH if facing == CompassDirection::NORTH
        return EAST if facing == CompassDirection::EAST
        return SOUTH if facing == CompassDirection::SOUTH
        return WEST if facing == CompassDirection::WEST
    end
end

class Tabletop
    attr_reader :extent

    def initialize(x, y)
        @extent = Vector.new(x, y)
    end

    def is_in_bounds(location)
        location.x <= @extent.x && location.y <= @extent.y &&
        location.x >= 0 && location.y >= 0
    end
end

class Robot
    attr_accessor :location, :facing
    attr_accessor :tabletop
    attr_accessor :has_been_placed

    def place(tabletop, x, y, facing)
        desired_location = Vector.new(x, y)
        if tabletop.is_in_bounds(desired_location)
            @tabletop = tabletop
            @location = desired_location
            @facing = facing
            @has_been_placed = true
            # puts("PLACE #{@location.x},#{@location.y},#{CompassDirection.get_direction_text_from_index(@facing)}")
        # else
        #     puts("Tried to place out of bounds.")
        end
    end

    def move()
        # Ensure that we've been placed first
        if @has_been_placed
            move_delta = DeltaMovements::get_delta_movement_in_direction(@facing)
            requested_location = Vector.new(@location.x + move_delta.x, @location.y + move_delta.y)
            is_allowed = @tabletop.is_in_bounds(requested_location)

            if(is_allowed)
                @location = requested_location
                # puts("Moving to new location.")
            # else
            #     puts("Ignoring out of bounds move.")
            end

            puts("Location is: #{@location.to_s}")
        # else
        #     puts("Ignoring command. Requires a PLACE command first.")
        end
    end

    def left()
        @facing = CompassDirection.turn_from_direction(@facing, true) if @has_been_placed
    end

    def right()
        @facing = CompassDirection.turn_from_direction(@facing, false) if @has_been_placed
    end

    def report()
        puts("Output: #{@location.x},#{@location.y},#{CompassDirection.get_direction_text_from_index(@facing)}") if @has_been_placed
    end
end

# Create objects
t = Tabletop.new(5, 5)
r = Robot.new()

# Process moves
moves = File.readlines("moves1.txt", chomp: true)
moves.each do |m|
    if m.match(/PLACE [0-9]*,[0-9]*,(NORTH|EAST|SOUTH|WEST)/)
        params = m[6..m.size].split(",")
        r.place(t,
            params[0].to_i,
            params[1].to_i,
            CompassDirection.get_index_from_direction_text(params[2])
        )
    elsif m.match(/(MOVE|LEFT|RIGHT|REPORT)/)
        r.send(m.downcase)
    else
        puts("You are talking gibberish")
    end
end

# binding.pry