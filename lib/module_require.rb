module ModuleRequire
  def module_require(filepath, desired_constants = false)
    filepath = filepath.slice(-3..-1) == ".rb" ? filepath : filepath + ".rb"
    file_contents = File.read(full_filepath(filepath))

    intermediate_module = Module.new
    intermediate_module.module_eval(file_contents)
    transferrable_constants = desired_constants ? desired_constants : intermediate_module.constants

    copy_constants(intermediate_module, transferrable_constants)

    nil
  end

  def full_filepath(filepath)
    $LOAD_PATH
      .lazy
      .map { |path| File.join(path, filepath) }
      .detect { |path| File.exist?(path) } || ""
  end

  def require(filepath)
    module_require(filepath)
  end

  def copy_constants(source, list)
    list.each do |name|
      const_set(name, source.const_get(name))
    end
  end
end
