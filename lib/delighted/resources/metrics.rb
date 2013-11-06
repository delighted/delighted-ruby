module Delighted
  class Metrics < Resource
    self.interface_name = "metrics"
    self.path = "/metrics"
    self.singleton_resource = true

    include Operations::Retrieve
  end
end
