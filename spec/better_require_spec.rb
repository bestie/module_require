require "spec_helper"

Module.class_eval do
  def better_require(filepath, import_module_name = nil)
    filepath = filepath[-3..-1] == ".rb" ? filepath : filepath + ".rb"
    file_contents = File.read(filepath)

    module_eval(file_contents)

    if import_module_name
      import_module = const_get(import_module_name)
      if import_module
        import_module.constants.each do |const_name|
          const_set(const_name, import_module.const_get(const_name))
        end

        remove_const(import_module_name)
      end
    end

    self
  end

  def require(filepath)
    better_require(filepath)
  end
end

describe Module do
  let(:new_module)         { Module.new }
  let(:test_lib_file_path) { "spec/support/library" }

  describe "#better_require" do
    it "returns self" do
      expect(
        new_module.better_require(test_lib_file_path)
      ).to be(new_module)
    end

    it "loads the library module into the new module" do
      new_module.better_require(test_lib_file_path)

      expect(new_module.constants).to eq([:Library])
    end

    it "does not bork the libraries internal constants" do
      new_module.better_require(test_lib_file_path)

      library_in_new_module = new_module.const_get(:Library)

      expect(library_in_new_module.constants)
        .to match_array([:LIBRARY_CONSTANT, :LibraryClass])
    end

    it "does not pollute the global object space" do
      expect(::Object.constants).not_to include(:Library)
    end

    context "when two copies of the same library are loaded" do
      let(:mod1) { Module.new }
      let(:mod2) { Module.new }

      it "can load them into separate modules" do
        mod1.better_require(test_lib_file_path)
        mod2.better_require(test_lib_file_path)

        expect(mod1.constants).to include(:Library)
        expect(mod2.constants).to include(:Library)
      end
    end

    context "when the library requires another supporting library" do
      let(:test_lib_file_path) { "spec/support/library_with_support" }

      it "loads both library and supporting library module into the new module" do
        new_module.better_require(test_lib_file_path)

        expect(new_module.constants).to match_array([:Library, :SupportingLibrary])
      end

      it "does not bork constant lookup within the library" do
        new_module.better_require(test_lib_file_path)

        aupporting_library_constants = new_module
          .const_get("SupportingLibrary::SupportingClass")

        expect(
          new_module
            .const_get("Library::LibraryClass")
            .get_constants_from_supporting_library
        ).to eq(new_module.const_get("SupportingLibrary::SupportingClass"))
      end
    end

    context "when module name is specified" do
      it "expands the specified module into the new module" do
        new_module.better_require(test_lib_file_path, :Library)

        expect(new_module.constants).to match_array([:LibraryClass, :LIBRARY_CONSTANT])
      end
    end
  end
end
