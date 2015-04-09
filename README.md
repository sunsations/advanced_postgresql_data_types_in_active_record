# README

This app shows the various awesome feature of postgres integrated in rails.

## Setup
````
bundle install
bundle exec rake db:create
bundle exec rake db:seed
````

You now have a populated database with products.

## [HSTORE](http://www.postgresql.org/docs/9.1/static/hstore.html)

### Facts
- the defining characteristic of hstore is the lack of a fixed schema
- must be enabled (CREATE EXTENSION hstore) in a migration (db/migrate/20150409075011_setup_hstore.rb).
- useful in various scenarios, such as rows with many attributes that are rarely examined, or semi-structured data
- maps string keys to string values
- a value (but not a key) can be an SQL NULL
- each key in an hstore is unique
- keys and values are simply text strings.
- in Rails you can use serialized attributes, but this approach has a problem: you can’t query the stored values

### Pros
1. ability to index on it
2. robust support for various operators
3. flexibility with your data

### Cons
1. it only deals with text
2. its not a full document store meaning you can’t nest objects. It was [rejected](http://www.sigaev.ru/git/gitweb.cgi?p=hstore.git;a=blob_plain;f=README;hb=HEAD) in favor for jsonb.

### Active Record
#### Find all products that have a key of 'author' in data
`Product.where("data ? :key", :key => 'author') # SQL => SELECT "products".* FROM "products" WHERE (data ? 'author')`

#### Find the number of products that have a key of 'author' in data
`Product.where("data ? :key", :key => 'author').count  # SQL => SELECT COUNT(*) FROM "products" WHERE (data ? 'author')`

#### Find the first product that have a key of 'author' in data
`Product.where("data ? :key", :key => 'author').first # SQL => SELECT  "products".* FROM "products" WHERE (data ? 'author')  ORDER BY "products"."id" ASC LIMIT 1`

#### Find all products from author Thomas Arni
`Product.where("data -> 'author' = 'Thomas Arni'") # SQL => SELECT "products".* FROM "products" WHERE (data -> 'author' = 'Thomas Arni')`

#### Find all products having key 'author' and value like 'Th' in data
`Product.where("data -> :key LIKE :value", :key => 'author', :value => "%Kat%") # SQL => SELECT COUNT(*) FROM "products" WHERE (data -> 'author' LIKE '%th%')`

#### Get attributes
````
Product.first.data # => {"author"=>"Thomas Arni", "category"=>"rails"}
Product.first.data['author'] # => "Thomas Arni"
````

#### Update attributes

````
first = Product.first
first.data['category'] = "ruby"
first.save
Product.first.data # => {"author"=>"Thomas Arni", "category"=>"ruby"}

first = Product.first
first.data = {a: 'b', c: 'd'}
first.save
Product.first.data # => {"a"=>"b", "c"=>"d"}
````
