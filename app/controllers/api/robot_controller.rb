class Api::RobotController < ApplicationController
  WIDTH = 5
  HEIGHT = 5

  def orders
    @location = nil
    @error_message = nil

    params[:commands].each do |command|
      case command
      when /^PLACE (\d+),(\d+),(NORTH|EAST|SOUTH|WEST)$/
        handle_place_command($1.to_i, $2.to_i, $3)
      when "MOVE"
        handle_move_command
      when "LEFT"
        handle_turn_command("LEFT")
      when "RIGHT"
        handle_turn_command("RIGHT")
      when "REPORT"
        # Do nothing for REPORT command
      else
        @error_message = "Invalid command: #{command}"
      end

      break if @error_message
    end

    if @error_message
      render json: { error: @error_message }, status: :unprocessable_entity
    else
      render json: { location: @location }, status: :ok
    end
  end

  private

  def handle_place_command(x, y, direction)
    if x.between?(0, WIDTH - 1) && y.between?(0, HEIGHT - 1)
      @location = [x, y, direction]
    else
      @error_message = "Invalid placement. Robot will fall off the table."
    end
  end

  def handle_move_command
    if @location
      x, y, direction = @location
      case direction
      when "NORTH"
        y += 1
      when "EAST"
        x += 1
      when "SOUTH"
        y -= 1
      when "WEST"
        x -= 1
      else
        @error_message = "Invalid move"
      end
      @location = [x, y, direction] if x.between?(0, WIDTH - 1) && y.between?(0, HEIGHT - 1)
    end
  end

  def handle_turn_command(turn_direction)
    if @location
      x, y, direction = @location
      new_direction = case direction
                      when "NORTH"
                        turn_direction == "LEFT" ? "WEST" : "EAST"
                      when "EAST"
                        turn_direction == "LEFT" ? "NORTH" : "SOUTH"
                      when "SOUTH"
                        turn_direction == "LEFT" ? "EAST" : "WEST"
                      when "WEST"
                        turn_direction == "LEFT" ? "SOUTH" : "NORTH"
                      else
                        @error_message = "Invalid move"
                      end
      @location = [x, y, new_direction]
    end
  end
end
