# README

This app shows the various awesome feature of postgres integrated in rails.

## Go readings:
- [Active Record and PostgreSQL](http://edgeguides.rubyonrails.org/active_record_postgresql.html)
- [Using PostgreSQL and hstore with Rails](http://nandovieira.com/using-postgresql-and-hstore-with-rails)
- [Postgresql's Jsonb brings all the NOSQL you'll ever need into Rails](https://antoine.finkelstein.fr/postgresql-jsonb-brings-nosql-into-rails/)

## Setup
````
bundle install
bundle exec rake db:setup
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

#### Find all products from author Thomas Arni
`Product.where("data -> 'author' = 'Thomas Arni'") # SQL => SELECT "products".* FROM "products" WHERE (data -> 'author' = 'Thomas Arni')`

#### Find all products having key 'author' and value like 'Th' in data
`Product.where("data -> :key LIKE :value", :key => 'author', :value => "%Th%") # SQL => SELECT COUNT(*) FROM "products" WHERE (data -> 'author' LIKE '%th%')`


#### Find with surus gem
````
Product.hstore_has_key(:data, "author")
Product.hstore_has_pairs(:data, "author" => "Thomas Arni")
```

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


## [Array](http://www.postgresql.org/docs/9.3/static/arrays.html)
Database column must be created the data type array.

### Active Record
#### Products with a one star rating
`Product.where("1 = ANY (ratings)")`

#### Products with 4 or 5 start ratings
`Product.where("ratings @> ARRAY[?]::int[]", [5,4])`

#### Products with 3 or more ratings
`Product.where("array_length(ratings, 1) >= 3")`

#### Find with surus gem
````
Product.array_has(:ratings, 1)
Product.array_has_any(:ratings, 5,4)
```

#### Update attributes
````
last = Product.last
last.ratings << 5
last.save

last = Product.last
last.ratings = [5,3]
last.save
Product.last.ratings # => [5, 3]
````


## [JSON](http://www.postgresql.org/docs/9.3/static/datatype-json.html)
- supports nested objects and more datatypes.

### Active Record
#### Products which are published
`Product.where("metadata->>'published' = ?", "true")`

#### Products which are from Switzerland (nested query)
````
Product.where("metadata -> 'nested' ->> 'country' = 'CH'")
# equivalent to
Product.where("metadata #>> '{nested,country}' = 'CH'")
````

#### Update attributes
````
last = Product.last
last.metadata = { whatever: 'you wish in a hash', even: { deep: "nesting", a: { b: 1} } }
last.save
````

### JSON vs JSONB
- json stores an exact copy of the text input, which must be reparsed again and again when you use any processing function. It doesn’t support indexes, but you can create an expression index for querying.
- jsonb stores a binary representation that avoids reparsing the data structure. It supports indexing, which means you can query any path without a specific index.
