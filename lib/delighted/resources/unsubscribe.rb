module Delighted
  class Unsubscribe < Resource
    self.path = '/unsubscribes'

    include Operations::Create
  end
end
