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
        (currently_facing + DIRECTIONS.length + (turn_left ? -1 : 1)) % DIRECTIONS.length
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
        location.x.between?(0, @extent.x) && location.y.between?(0, @extent.y)
    end
end

class Robot
    attr_reader :location, :facing, :tabletop, :has_been_placed

    def place(tabletop, x, y, facing)
        desired_location = Vector.new(x, y)
        if tabletop.is_in_bounds(desired_location)
            @tabletop = tabletop
            @location = desired_location
            @facing = facing
            @has_been_placed = true
        end
    end

    def move()
        if @has_been_placed
            requested_location = @location + DeltaMovements::get_delta_movement_in_direction(@facing)
            @location = requested_location if @tabletop.is_in_bounds(requested_location)
        end
    end

    def left()
        @facing = CompassDirection::turn_from_direction(@facing, true) if @has_been_placed
    end

    def right()
        @facing = CompassDirection::turn_from_direction(@facing, false) if @has_been_placed
    end

    def report()
        puts("Output: #{@location.x},#{@location.y},#{CompassDirection::get_direction_text_from_index(@facing)}") if @has_been_placed
    end
end

# Create objects
tabletop = Tabletop.new(5, 5)
robot = Robot.new()

# Process moves. I'm tired now so fuck it that's my excuse.
file_name = "moves_d.txt"

if !File.exists?(file_name)
    puts("Was expecting a file called #{file_name} in this directory. Aborting.")
else
    File.readlines(file_name, chomp: true).each do |m|
        if m.match(/^PLACE [0-9]*,[0-9]*,(NORTH|EAST|SOUTH|WEST)$/)
            params = m[6..m.size].split(",")
            robot.place(tabletop,
                params[0].to_i,
                params[1].to_i,
                CompassDirection::get_index_from_direction_text(params[2])
            )
        elsif m.match(/^(MOVE|LEFT|RIGHT|REPORT)$/)
            robot.send(m.downcase)
        # elsif m.match(/^Output: [0-9]*,[0-9]*,(NORTH|EAST|SOUTH|WEST)$/)
        # else
        #     puts("You are talking gibberish")
        end
    end
end