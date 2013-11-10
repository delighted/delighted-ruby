module Delighted
  class Person < Resource
    self.path = "/people"

    include Operations::Create
  end
end
