word_list = %w(pool loco cool stain satin pretty nice loop)

puts "=== Anagram Finder ==="
puts "Original list: #{word_list.join(' ')}"

def map_word(word)
  letters = {}
  hash = ''

  word.split('').each do |char|
    letters[char] ||= 0
    letters[char] += 1
  end

  letters.keys.sort.each do |key|
    hash += "#{key}#{letters[key]}"
  end

  hash
end

def process_list(word_list)
  map = {}
  output = Array.new(word_list.count)

  word_list.each_with_index do |word, i|
    hash = map_word(word)
    map[hash] ||= []
    map[hash] << "#{word}::#{i}"

    if map[hash].length >= 2
      map[hash].each do |w|
        w =~ /.*?::(\d+)/
        index = $1.to_i
        output[index] = w.gsub(/::\d+/,'')
      end
    end
  end
  output.compact
end

puts "Processed list: #{process_list(word_list).join(' ')}"
