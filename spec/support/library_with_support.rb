require "supporting_library"

module Library
  LIBRARY_CONSTANT = "Library's Constant"

  class LibraryClass
    def self.get_constants_from_supporting_library
      SupportingLibrary::SupportingClass
    end
  end
end
