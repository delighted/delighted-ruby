module Delighted
  class Person < Resource
    self.interface_name = "people"
    self.path = "/people"

    include Operations::Create
  end
end
