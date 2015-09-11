#!/bin/env ruby

class MonitorSetup
  def fetch_displays
    `xrandr`.scan(/(\w+\s*disconnected)/)
  end

  def run
    p fetch_displays
  end
end

m = MonitorSetup.new
m.run

