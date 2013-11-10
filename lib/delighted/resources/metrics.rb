module Delighted
  class Metrics < Resource
    self.path = "/metrics"
    self.singleton_resource = true

    include Operations::Retrieve
  end
end
