require "spec_helper"

Module.class_eval do
  def better_require(filepath, desired_constants = false)
    filepath = filepath.slice(-3..-1) == ".rb" ? filepath : filepath + ".rb"
    file_contents = File.read(filepath)

    intermediate_module = Module.new
    intermediate_module.module_eval(file_contents)
    transferrable_constants = desired_constants ? desired_constants : intermediate_module.constants

    copy_constants(intermediate_module, transferrable_constants)

    nil
  end

  def require(filepath)
    better_require(filepath)
  end

  def copy_constants(source, list)
    list.each do |name|
      const_set(name, source.const_get(name))
    end
  end
end

describe Module do
  let(:new_module)         { Module.new }
  let(:test_lib_file_path) { "spec/support/library" }

  describe "#better_require" do
    it "returns nil" do
      expect(
        new_module.better_require(test_lib_file_path)
      ).to be(nil)
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

    context "when a specific list of constants is supplied" do
      let(:test_lib_file_path) { "spec/support/lib_with_two_top_level_modules" }
      let(:desired_constants) { [:LibWithTwoTopLevelModulesGoodModule] }
      let(:undesired_constants) { [:LibWithTwoTopLevelModulesBadModule] }

      it "imports the specified constants" do
        new_module.better_require(test_lib_file_path, desired_constants)

        expect(new_module.constants).to include(*desired_constants)
      end

      it "rejects any further constants" do
        new_module.better_require(test_lib_file_path, desired_constants)

        expect(new_module.constants).not_to include(*undesired_constants)
      end
    end
  end
end
