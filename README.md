nouns-with-plurals
==================

Scripts create lists of English nouns with plural forms using Wiktionary dump. It can be used to transform noun to singular or plural form.

Files:
* noun.csv - countable nouns
* noun_countable_and_uncountable.csv - e.g. http://en.wiktionary.org/wiki/beers
* noun_uncountable.csv - nouns that cannot be used freely with numbers or the indefinite article, and which therefore takes no plural form
* noun_usually_uncountable.csv - e.g. http://en.wiktionary.org/wiki/information
* noun_unknown.csv - nouns with unknown or uncertain plural
* noun_pluralia_tantum - nouns that has no singular form, e.g. http://en.wiktionary.org/wiki/scissors
* noun_not_attested.csv - nouns with plural not attested

Usage:

`ruby parser.rb enwiktionary-20140206-pages-meta-current.xml`
`ruby process_templates.rb`