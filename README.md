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

_**Why did I choose this hash method?**_ It seemed right at the time and I originally
thought it would save space. Upon reading more of the original blog post, Nafiul
ends up creating a hash of a word by sorting the letters alphabetically, which
is much faster/nicer. I'm keeping my hashing function as-is for full-disclosure.

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
  output = Array.new

  word_list.each_with_index do |word, index|
    hash = map_word(word)
    word_set[hash] ||= []
    word_set[hash] << wrap_word_with_index(word, index)

    # If there are at least 2 words in the set, we have something worth outputting
    if word_set[hash].length >= 2
      word_set[hash].each do |w|
        word, i = unwrap_word_and_index(w)
        # Place the word in it's original index/placement of the original string
        output.insert(i, word)
      end
    end
  end
  # Get rid of those pesky nils
  output.compact
end
</pre>

## Does it work?

Yes, it does. It's still a hot mess. Problems I see are:

1. My "word:index" *works*, but I'm not in love with it. That value has to be stored *somewhere*, so alongside the word is probably fine, but, it feels messy. I could just do an `.index_of` lookup on the original `word_list`, but that's technically a scan of the original word list, which would happen for every word I'm going to output.
2. My hashing-function is a bit verbose/overkill when sorting the letters of a word would also work. I'm keeping the original here.

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
#=> Processed list: pool loco cool stain satin loop
</pre>

## How about a refactor?
Knowing what I know now, and seeing the problems, let's do some refactoring.

### Hashing function
Let's first simplify the function to do a letter-sort. It now becomes much shorter:

<pre class='prettyprint'>
def hash_word(word)
  word.split('').sort
end
</pre>

Wow, I'm embarrassed.

### Wrap/Unwrap functions
Why didn't I just use a hash, or an array?

<pre class='prettyprint'>
# No need for an unwrap function now, this is simple.
# Heck, even this function seems overkill, now.
def wrap_word_with_index(word, index)
  [word, index]
end
# ... snip ...
if word_set[hash].length >= 2
  word_set[hash].each do |word_index|
    word, i = word_index # it's in the format I need already! how quaint
    # Place the word in it's original index/placement of the original string
    output.insert(i, word)
  end
end
</pre>

`embarassment++`

## Refactored full code

Now that the code is cleaner/leaner, here's the full dump:

<pre class='prettyprint'>
word_list = %w(pool loco cool stain satin pretty nice loop)

puts "=== Anagram Finder ==="
puts "Original list: #{word_list.join(' ')}"

def hash_word(word)
  word.split('').sort
end

def wrap_word_with_index(word, index)
  [word, index]
end

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
        output.insert(i, word)
      end
    end
  end
  output.compact
end

puts "Processed list: #{process_list(word_list).join(' ')}"
</pre>

Yeesh, that looks a lot better. Live, code and learn.
