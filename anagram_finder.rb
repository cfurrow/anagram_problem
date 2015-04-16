word_list = %w(pool loco cool stain satin pretty nice loop)

puts "=== Anagram Finder ==="
puts "Original list: #{word_list.join(' ')}"

# Given a word, creates a hash given the characteristics of the letters in the word
#
# @param word [String] the word to hash
# @return [String] the hash of the word
def hash_word(word)
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

# Given a word and the index, combines the two into a string
#
# @param word [String] the word
# @param index [String] the index of where the word appeared in the original string
# @return [String] the combination of the word and the index, e.g. 'foo:5'
def wrap_word_with_index(word, index)
  "#{word}:#{index}"
end

# Given a wrapped word from wrap_word_with_index, unwrap the string into a word
# and an index.
#
# @param word_index [String] the combined word and index in the format of "foo:5"
# @return [Array] an array contining the word, then the index, in that order
def unwrap_word_and_index(word_index)
  match = /(\w+):(\d+)/.match(word_index)
  [match[1], match[2].to_i]
end

# Processes a word list
#
# @param word_list [Array] an array of words to search for anagram-matches in
# @return [Array] an array of all the anagrams found in the original word list
def process_list(word_list)
  word_set = {}
  output = []

  word_list.each_with_index do |word, index|
    hash = hash_word(word)
    word_set[hash] ||= []
    word_set[hash] << wrap_word_with_index(word, index)

    if word_set[hash].length >= 2
      word_set[hash].each do |w|
        word, i = unwrap_word_and_index(w)
        # Place the word in it's original index/placement of the original string
        output.insert(i, word)
      end
    end
  end
  output.compact
end

puts "Processed list: #{process_list(word_list).join(' ')}"
