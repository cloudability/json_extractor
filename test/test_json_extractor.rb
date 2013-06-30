require 'helper'

class TestJsonExtractor < Test::Unit::TestCase
  def test_extracts_json
    extracted = JSONExtractor.extract_subdocument(fixture_path("simple_document"), "my_key")
    assert(extracted =~ /\s+{\s+"first": 1\s+}/, "extracted #{extracted.inspect}")
  end

  def test_extracts_nested_json
    extracted = JSONExtractor.extract_subdocument(fixture_path("nested_document"), "my_key")
    assert(extracted =~ /\s*{\s+"my_other_key":\s+{\s+"something": 1\s+}\s+}/, "extracted #{extracted.inspect}")
  end

  def test_extracts_extra_nested_json
    extracted = JSONExtractor.extract_subdocument(fixture_path("extra_nested_document"), "some_key")
    assert(extracted =~ /\s*{\s+"my_key":\s+{\s+"my_other_key":\s+{\s+"something": 1\s+}\s+}\s+}/, "extracted #{extracted.inspect}")
  end

  def test_extracts_nested_keys
    extracted = JSONExtractor.extract_subdocument(fixture_path("extra_nested_document"), "my_other_key")
    assert(extracted =~ /\s*{\s+"something": 1\s+}/, "extracted #{extracted.inspect}")
  end
end
