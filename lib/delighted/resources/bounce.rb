module Delighted
  class Bounce < Resource
    self.path = '/bounces'

    include Operations::All
  end
end
