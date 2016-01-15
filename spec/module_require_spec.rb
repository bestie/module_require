require "spec_helper"

require "module_require"

Module.class_eval do
  include ModuleRequire
end

RSpec.describe Module do
  before(:all) do
    $LOAD_PATH.push("./spec/support")
  end

  let(:new_module)         { Module.new }
  let(:test_lib_file_path) { "library" }

  describe "#module_require" do
    it "returns nil" do
      expect(
        new_module.module_require(test_lib_file_path)
      ).to be(nil)
    end

    it "loads the library module into the new module" do
      new_module.module_require(test_lib_file_path)

      expect(new_module.constants).to eq([:Library])
    end

    it "does not bork the libraries internal constants" do
      new_module.module_require(test_lib_file_path)

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
        mod1.module_require(test_lib_file_path)
        mod2.module_require(test_lib_file_path)

        expect(mod1.constants).to include(:Library)
        expect(mod2.constants).to include(:Library)
      end
    end

    context "when the library requires another supporting library" do
      let(:test_lib_file_path) { "library_with_support" }

      it "loads both library and supporting library module into the new module" do
        new_module.module_require(test_lib_file_path)

        expect(new_module.constants).to match_array([:Library, :SupportingLibrary])
      end

      it "does not bork constant lookup within the library" do
        new_module.module_require(test_lib_file_path)

        supporting_library_constants = new_module
          .const_get("SupportingLibrary::SupportingClass")

        expect(
          new_module
            .const_get("Library::LibraryClass")
            .get_constants_from_supporting_library
        ).to eq(supporting_library_constants)
      end
    end

    context "when a specific list of constants is supplied" do
      let(:test_lib_file_path) { "lib_with_two_top_level_modules" }
      let(:desired_constants) { [:LibWithTwoTopLevelModulesGoodModule] }
      let(:undesired_constants) { [:LibWithTwoTopLevelModulesBadModule] }

      it "imports the specified constants" do
        new_module.module_require(test_lib_file_path, desired_constants)

        expect(new_module.constants).to include(*desired_constants)
      end

      it "rejects any further constants" do
        new_module.module_require(test_lib_file_path, desired_constants)

        expect(new_module.constants).not_to include(*undesired_constants)
      end
    end
  end
end
