Product.delete_all


Product.create(:name => "PostgreSQL with Rails Awesomeness", :data => {'author' => 'Thomas Arni',  'category' => 'rails'})

(1..1000).each do |i|
  product = if i % 3 == 0
    Product.create(:name => Faker::Commerce.product_name, :data => {'author' => Faker::Name.name, 'category' => Faker::Lorem.word})
  else
    Product.create(:name => Faker::Commerce.product_name, :data => {'author' => Faker::Name.name, 'pages' => rand(100..600), 'category' => Faker::Lorem.word, 'isbn' => Faker::Code.isbn})
  end
  puts product.inspect
end

puts Product.last.data['category']  # => 'fiction'
