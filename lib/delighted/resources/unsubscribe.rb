module Delighted
  class Unsubscribe < Resource
    self.path = '/unsubscribes'

    include Operations::All
    include Operations::Create
  end
end
