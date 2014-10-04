#!/usr/bin/env ruby
# encoding: utf-8

require 'csv'
require 'progress'

def split_languages(raw)
  langs = []
  lang_raw = ''
  lang = nil
  raw.split("\n").each do |line|
    match = /^==[^=]*?\(\{\{(.*?)\}\}\)[^=]*?==$/.match(line.strip)
    if not match.nil?
      if not lang.nil?
        langs.push([lang,lang_raw])
      end
      lang_raw = ''
      lang = match[1]
    else
      lang_raw += line+"\n"
    end
  end
  if not lang.nil?
    langs.push([lang,lang_raw])
  end
  return langs
end

def parse(page)
  #puts page
  title_match = /<title>(.*?)<\/title>/m.match(page)
  match = /<text xml:space="preserve">(.*?)<\/text>/m.match(page)
  return false if not match
  title = title_match[1]
  
  if title.include?(':') #|| title.start_with?("Wiktionary:", "Talk:", "User talk:", "User:", 'Appendix:', 'Help talk:','Citations:')
    return false
  end
  
  raw = match[1]
  #puts raw
  #split by languages
  langs = split_languages(raw)
  #p langs
  #puts title
  templates = nil
  c=0
  langs.each do |lang,lang_raw|
    if lang == 'język polski'
      c+=1

      templates = lang_raw.scan(/{{(?:IPA[2-4]?).*?}}/)

      if c>1
        puts 'More than one ==English== definitions', title
        #puts page
      end
    end
  end
  
  if not templates.nil?
    return [title, templates]
  end


  
  return false
end

f = File.open(ARGV[0])
o = CSV.open('word_templates_pl.csv','w')

page = ''
Progress.start(f.size)
f.each do |line|
  Progress.set(f.pos)
  if line.strip == '<page>'
    page = ''
  elsif line.strip == '</page>'
    result = parse(page)
    next if not result
    title, templates = result
    #p result
    if not templates.empty?
      o << [title] + templates
      o.flush
    end
  else
    page += line
  end
  
  
end
Progress.stop

f.close
o.close