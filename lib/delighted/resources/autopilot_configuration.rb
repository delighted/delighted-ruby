module Delighted
  class AutopilotConfiguration < Resource
    self.path = "/autopilot"

    include Operations::Retrieve
  end
end
