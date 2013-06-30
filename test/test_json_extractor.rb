require 'helper'

class TestJsonExtractor < Test::Unit::TestCase
  def extract_from(document, key)
    JSONExtractor.extract_subdocument(fixture_path(document), key)
  end

  def test_extracts_json
    extracted = extract_from("simple_document", "my_key")
    assert(extracted =~ /\s+{\s+"first": 1\s+}/, "extracted #{extracted.inspect}")
  end

  def test_extracts_nested_json
    extracted = extract_from("nested_document", "my_key")
    assert(extracted =~ /\s*{\s+"my_other_key":\s+{\s+"something": 1\s+}\s+}/, "extracted #{extracted.inspect}")
  end

  def test_extracts_extra_nested_json
    extracted = extract_from("extra_nested_document", "some_key")
    assert(extracted =~ /\s*{\s+"my_key":\s+{\s+"my_other_key":\s+{\s+"something": 1\s+}\s+}\s+}/, "extracted #{extracted.inspect}")
  end

  def test_extracts_nested_keys
    extracted = extract_from("extra_nested_document", "my_other_key")
    assert(extracted =~ /\s*{\s+"something": 1\s+}/, "extracted #{extracted.inspect}")
  end

  def test_returns_nil_when_key_is_not_found
    extracted = extract_from("extra_nested_document", "some_key_that_does_not_exist")
    assert(extracted.nil?, "expected result to be nil")
  end

  def test_returns_nil_when_document_is_not_formatted_properly
    extracted = extract_from("bad_document", "some_key")
    assert(extracted.nil?, "expected result to be nil but was #{extracted.inspect}")
  end

  def test_extracts_from_json_string_passed_in
    json = File.read(fixture_path("extra_nested_document"))
    extracted = JSONExtractor.extract_subdocument(json, "some_key")
    assert(extracted =~ /\s*{\s+"my_key":\s+{\s+"my_other_key":\s+{\s+"something": 1\s+}\s+}\s+}/, "extracted #{extracted.inspect}")
  end

  def test_extracts_arrays
    extracted = extract_from("basic_array_document", "some_key")
    assert(extracted == " [1,2,3,4,5]", "extracted #{extracted.inspect}")
  end

  def test_extracts_arrays_even_when_nested
    extracted = extract_from("nested_array_document", "some_key")
    assert(!extracted.nil?, "extracted #{extracted.inspect}")
  end

  def test_creates_subdocuments_from_arrays
    assert_nothing_raised do
      JSONExtractor.subdocument(fixture_path("nested_array_document"), "some_key")
    end
  end

  def test_creates_subdocuments_from_objects
    assert_nothing_raised do
      JSONExtractor.subdocument(fixture_path("simple_document"), "my_key")
    end
  end
end
