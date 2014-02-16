require 'csv'
require 'progress'

file_templates = CSV.open('word_templates.csv')


nouns = ['noun','noun_uncountable','noun_usually_uncountable','noun_countable_and_uncountable','noun_non_attested','noun_unknown','noun_pluralia_tantum','noun_proper']
files = Hash.new
nouns.each do |noun|
  files[noun]=CSV.open(noun+'.csv','w')
end


def generate_plurals(word, modifier, rest)
  if rest.empty?
    if ['-','!'].include?(modifier)
      return []
    else
      return [word+'s']
    end
  elsif not modifier.nil? and modifier=='!'
    return []
  else
    plurals=[]
    rest.each do |plural|
      if ['s','es'].include?(plural)
        plurals.push word+plural
      else
        match = /=(.*)/.match(plural)
        if not match.nil?
          plural = match[1]
        end
        plurals.push plural
      end
    end
    return plurals
  end
end

file_templates.each do |word,*templates|
  templates.each do |template|
    
    match_rest = /\|(.*)}}/.match(template)
    if not match_rest.nil?
      rest=match_rest[1].gsub(/\[\[.*?\]\] ?/, '').split('|').select{|v| (not v =~ /=/) or v.start_with?('plural=','pl2=','pl3=','pl4=') }
    else
      rest = []
    end
    #puts word, rest
    
    if template.start_with?('{{en-noun')
      file = files['noun']
      modifier = nil
      if not rest.empty? and ['-','~','?','!'].include?(rest[0])
        modifier = rest.shift
        if modifier=='-'
          if rest.empty?
            file = files['noun_uncountable']
          else
            file = files['noun_usually_uncountable']
          end
        elsif modifier=='~'
          file = files['noun_countable_and_uncountable']
        elsif modifier=='?'
          file = files['noun_unknown']
        elsif modifier=='!'
          file = files['noun_non_attested']
        end
      end
      
      plurals = generate_plurals(word, modifier, rest)
      #p plurals
      file << [word] + plurals
      
    elsif template.start_with?('{{en-plural noun')
      file = files['noun_pluralia_tantum']
      file << [word]
      
    elsif template.start_with?('{{en-prop','{{en-proper noun','{{en-proper-noun')
      file = files['noun_proper']
      #plurals = generate_plurals(word, nil, rest)
      #p word, rest if not rest.empty?
      file << [word] + [template]
    end
      
  end
end

files.each do |noun,file|
  file.close
end

nouns.each do |noun|
  `cp #{noun}.csv tmp`
  `sort tmp > #{noun}.csv`
end
`rm tmp`