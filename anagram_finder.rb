word_list = %w(pool loco cool stain satin pretty nice loop)

puts "=== Anagram Finder ==="
puts "Original list: #{word_list.join(' ')}"

# Given a word, creates a hash given the characteristics of the letters in the word
#
# @param word [String] the word to hash
# @return [String] the letters of the word sorted alphabetically,
#   "cool" becomes "cloo", "loco" also becomes "cloo"
def hash_word(word)
  word.split('').sort
end

# Given a word and the index, combines the two into a string
#
# @param word [String] the word
# @param index [String] the index of where the word appeared in the original string
# @return [Array] outputs the [word, index] as an array, in that order
def wrap_word_with_index(word, index)
  [word, index]
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
      word_set[hash].each do |word_index|
        word, i = word_index
        # Place the word in it's original index/placement of the original string
        output.insert(i, word)
      end
    end
  end
  output.compact
end

puts "Processed list: #{process_list(word_list).join(' ')}"
