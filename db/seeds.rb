Product.delete_all


metadata = { pages: 400, published: false, isbn: SecureRandom.uuid }

Product.create(:name => "PostgreSQL with Rails Awesomeness", :data => {'author' => 'Thomas Arni',  'category' => 'rails'}, ratings: [5, 5, 5], metadata: { published: false })

(1..1000).each do |i|
  rating = ((1..5).to_a.shuffle * 4).first(rand(0..5))
  product = if i % 3 == 0
    metadata = { published: false, nested: { country: "CH" } }
    Product.create(:name => Faker::Commerce.product_name, :data => {'author' => Faker::Name.name, 'category' => Faker::Lorem.word}, ratings: rating, metadata: metadata)
  else
    metadata = { published: true, nested: { country: "DE" } }
    Product.create(:name => Faker::Commerce.product_name, :data => {'author' => Faker::Name.name, 'pages' => rand(100..600), 'category' => Faker::Lorem.word, 'isbn' => Faker::Code.isbn}, ratings: rating, metadata: metadata)
  end
  puts product.inspect
end

puts Product.last.data['category']  # => 'fiction'
