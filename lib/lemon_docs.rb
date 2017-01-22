require 'lemon_docs/binding'
require 'lemon_docs/version'
require 'ffi'
require 'json'

module LemonDocs
  include Binding

  def self.parse(raw_blueprint)
    fail(ArgumentError, 'Expected string value') unless raw_blueprint.is_a?(String)

    parse_result = FFI::MemoryPointer.new(:pointer)
    validation_result = FFI::MemoryPointer.new(:pointer)
    serialize_options = LemonDocs::SerializeOption.new
    serialize_options[:sourcemap] = 1
    serialize_options[:drafter_format] = 1

    if LemonDocs::Binding.drafter_check_blueprint(raw_blueprint, validation_result, 0) == 0
      LemonDocs::Binding.drafter_parse_blueprint_to(raw_blueprint, parse_result, 0, serialize_options)
      json_output(parse_result)
    else
      json_output(validation_result)
    end

  ensure
    LemonDocs::Memory.free(parse_result)
    LemonDocs::Memory.free(validation_result)
  end

  # Parses API Blueprint from a file.
  def self.parse_file(file_path)
    file = File.new(file_path)
    path = File.dirname(file_path)

    LemonDocs::Parser.parse(file.read, path)
  end

  private

  def self.json_output(result)
    result = result.get_pointer(0)
    JSON.parse(result.null? ? nil : result.read_string)
  end
end