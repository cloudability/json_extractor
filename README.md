# JSON Extractor

Pull out specific objects from a large JSON document by key without having to
deserialize the whole object in to Ruby.

**NOTE:** This gem only supports extracting objects and arrays from JSON
documents. Strings and numbers are not supported. Yet.

## Example

Assume that you have a JSON document:

``` json
{
  "number": 6,
  "name": "Darlington Nagbe",
  "position": "midfielder",
  "statistics": {
    "2012": {
      "gp": 33,
      "gs": 31,
      "g": 6,
      "min": 2777,
      "a": 1,
      "sht": 50,
      "sog": 16,
      "fc": 16,
      "off": 6,
      "y": 0,
      "r": 0
    }
  }
}
```

The JSON Extractor API will let you pull out a specific object withing that
file.

``` bash
$ irb
1.9.3p374 :002 > require 'json_extractor'
 => false
1.9.3p374 :001 > JSONExtractor.subdocument("/path/to/data.json", "statistics")
 => {"2012"=>{"gp"=>33, "gs"=>31, "g"=>6, "min"=>2777, "a"=>1, "sht"=>50, "sog"=>16, "fc"=>16, "off"=>6, "y"=>0, "r"=>0}}
```

## How does it work?

The actual implementation is done in C. The whole file is read into memory, the
key is found somewhere within the file, and the object associated with that key
is extracted using a simple recursive descent parser that's only aware of the
semantics of an object.

## Contributing to JSON Extractor
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

