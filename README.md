# The Anagram Problem

Taken from [http://nafiulis.me/the-deceptive-anagram-question.html](http://nafiulis.me/the-deceptive-anagram-question.html)

## Problem

> Given a list of words L, find all the anagrams in L in the order in which they appear in L.

## Example

The word list:

> ["pool", "loco", "cool", "stain", "satin", "pretty", "nice", "loop"]

The output should be, in *exactly* this order:

> ["pool", "loco", "cool", "stain", "satin", "loop"]

## Solution

I started reading the above post when I thought I should stop reading and try it
myself. I too, started with a very naive approach that was looping over the list
in exponential time. Gross.

As I read more, he said the interviewer suggested getting it to O(N) time by using
a hash map. I stopped reading once more, and went back to my half-baked problem.

I came up with something that processes the output as it's reading words in. It's
still rough, but it doesn't loop back over the list of words, which is nice.

### Step 1: Read in the words, remembering their place in the original string

<pre class='prettyprint'>
def process_list(word_list)
  word_list.each_with_index do |word, index|
    # ... more to come ...
  end
end
</pre>

### Step 2: Create a hash of the word that will map similar words to the same hash

I figured I'd create a hash of a word that took each letter, and the count of each
letter as it appeared in the word, the sort the letters and place the count next to it.

Example: The word "cool" would become "c1l1o2" since "c" and "l" only appear once,
and "o" appears twice. That would also map "loco" to the same hash. Nice.

<pre class='prettyprint'>
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
</pre>

### Step 3: As each word is read in, create the hash, and store the word in the set of hashes.

<pre class='prettyprint'>
def process_list(word_list)
  word_set = {}

  word_list.each_with_index do |word, index|
    hash = hash_word(word)
    # Default the word_set for hash to an empty array
    word_set[hash] ||= []

    # Append the word, plus its place in the original string
    word_set[hash] << "#{word}:#{index}"
    # ... more to come ...
  end
end
</pre>

As you can see, when I add the word to the hash map of words, I append it as
the word, plus its original place in line. I'll use that later when constructing
the output.

### Step 4: Build the output string

<pre class='prettyprint'>
def wrap_word_with_index(word, index)
  "#{word}:#{index}"
end

def unwrap_word_and_index(word_index)
  match = /(\w+):(\d+)/.match(word_index)
  [match[1], match[2].to_i]
end

def process_list(word_list)
  word_set = {}
  # Initialize an array the same size as the word_list, fill with nils
  output = Array.new(word_list.count)

  word_list.each_with_index do |word, index|
    hash = map_word(word)
    word_set[hash] ||= []
    word_set[hash] << wrap_word_with_index(word, index)

    # If there are at least 2 words in the set, we have something worth outputting
    if word_set[hash].length >= 2
      word_set[hash].each do |w|
        word, i = unwrap_word_and_index(w)
        # Place the word in it's original index/placement of the original string
        output[i] = word
      end
    end
  end
  # Get rid of those pesky nils
  output.compact
end
</pre>

## Does it work?

Yes, it does. It's still a hot mess. Problems I see are:

1. It builds a secondary array of words, fills it with nils, then removes those nils. Wasteful. Over-allocating.
2. My "word:index" *works*, but I'm not in love with it. That value has to be stored *somewhere*, so alongside the word is probably fine, but, it feels messy.

## Full code

<pre class='prettyprint'>
word_list = %w(pool loco cool stain satin pretty nice loop)

puts "=== Anagram Finder ==="
puts "Original list: #{word_list.join(' ')}"

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

def wrap_word_with_index(word, index)
  "#{word}:#{index}"
end

def unwrap_word_and_index(word_index)
  match = /(\w+):(\d+)/.match(word_index)
  [match[1], match[2].to_i]
end

def process_list(word_list)
  word_set = {}
  output = Array.new(word_list.count)

  word_list.each_with_index do |word, index|
    hash = hash_word(word)
    word_set[hash] ||= []
    word_set[hash] << wrap_word_with_index(word, index)

    if word_set[hash].length >= 2
      word_set[hash].each do |w|
        word, i = unwrap_word_and_index(w)
        # Place the word in it's original index/placement of the original string
        output[i] = word
      end
    end
  end
  output.compact
end

puts "Processed list: #{process_list(word_list).join(' ')}"
#=> Processed list: pool loco cool stain satin loop
</pre>
