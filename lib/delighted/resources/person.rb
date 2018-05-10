module Delighted
  class Person < Resource
    self.path = "/people"

    include Operations::Create
    include Operations::Delete
  end
end
