require 'tempfile'

namespace :benchmark do
  # The maximum depth for a given object.
  MAX_DEPTH     = 3

  # The number of keys to generate in each hash.
  MAX_KEYS      = 1000

  # The number of samples to generate.
  MAX_SAMPLES   = 5

  def string_or_number
    rand > 0.5 ? "a" * rand(200) : rand(200)
  end

  def generate_array(keys=10000)
    keys.times.map
  end

  def generate_random_hash(keys=MAX_KEYS, depth=0)
    keys.times.inject({}) do |h, n|
      if depth >= MAX_DEPTH
        h[n] = string_or_number
      else
        case rand(10)
        when 0 then h[n] = string_or_number
        when 1..8 then h[n] = generate_array
        when 9 then h[n] = generate_random_hash(keys / 2, depth+1)
        end
      end

      h
    end
  end

  def time(&blk)
    start_at = Time.now
    blk.call
    Time.now - start_at
  end

  desc "Benchmark speed vs. directly decoding."
  task :speed do
    require 'json'
    require File.expand_path('../../json_extractor', __FILE__)

    file_sizes = []
    old_method, extractor = [[], []]

    MAX_SAMPLES.times do |i|
      print "\rGenerating sample #{i+1}/#{MAX_SAMPLES}                      "

      tempfile = Tempfile.new("benchmark-#{i}")

      obj = generate_random_hash
      obj["my_target_string"] = { key: "value" }

      tempfile.write(obj.to_json)
      tempfile.close

      file_sizes << File.size(tempfile.path)

      time1 = time do
        json = JSON.parse(File.read(tempfile.path))
        json["my_target_string"]
      end

      time2 = time do
        JSONExtractor.subdocument(tempfile.path, "my_target_string")
      end

      old_method << time1
      extractor << time2

      tempfile.unlink
    end

    puts "\rGenerated #{MAX_SAMPLES} samples.                              "

    avg_old_method = old_method.reduce(&:+) / old_method.length.to_f
    avg_extractor = extractor.reduce(&:+) / extractor.length.to_f
    avg_file_size = file_sizes.reduce(&:+) / file_sizes.length.to_f

    puts "Average file size:\t\t\t#{'%0.02f' % (avg_file_size / 2**20)}MB"
    puts "Average JSON.parse time:\t\t#{'%0.04f' % avg_old_method}s"
    puts "Average JSONExtractor.subdocument time:\t#{'%0.04f' % avg_extractor}s"
    puts "Average speed increase:\t\t\t#{'%0.02f' % ((1 - (avg_extractor / avg_old_method)) * 100.0)}%"
  end
end
