

class DuplicateElementException < Exception
end

module Comparable
  # Compare Elem objects by name and type_name
  def <=>(elem)
    comparison = self.name <=> elem.name

    if comparison == 0
      return self.type_name <=> elem.type_name
    else
      return comparison
    end
  end
end

