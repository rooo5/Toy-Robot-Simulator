class Api::RobotController < ApplicationController
  WIDTH = 5
  HEIGHT = 5

  def orders
    @location = nil
    @error_message = nil

    params[:commands].each do |command|
      case command
      when /^PLACE (\d+),(\d+),(NORTH|EAST|SOUTH|WEST)$/
        x = $1.to_i
        y = $2.to_i
        direction = $3

        if x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT
          @location = [x, y, direction]
        else
          @error_message = "Invalid placement. Robot will fall off the table."
        end
      when "MOVE"
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
          end

          if x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT
            @location = [x, y, direction]
          end
        end
      when "LEFT"
        if @location
          x, y, direction = @location

          case direction
          when "NORTH"
            direction = "WEST"
          when "EAST"
            direction = "NORTH"
          when "SOUTH"
            direction = "EAST"
          when "WEST"
            direction = "SOUTH"
          end

          @location = [x, y, direction]
        end
      when "RIGHT"
        if @location
          x, y, direction = @location

          case direction
          when "NORTH"
            direction = "EAST"
          when "EAST"
            direction = "SOUTH"
          when "SOUTH"
            direction = "WEST"
          when "WEST"
            direction = "NORTH"
          end

          @location = [x, y, direction]
        end
      when "REPORT"
        
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
end