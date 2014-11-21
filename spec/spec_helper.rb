$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rspec'
require 'factory_girl'
require 'active_record'
require 'authorizable'
require 'models/forum'
require 'models/forum_membership'
require 'models/forum_thread'
require 'models/post'
require 'models/role'
require 'models/user'

# Configure the Logger and database connection
ActiveRecord::Base.logger = Logger.new(StringIO.new)
ActiveRecord::Base.configurations = {
    'sqlite' => {adapter: 'sqlite', database: ':memory:'},
    'sqlite3' => {adapter: 'sqlite3', database: ':memory:'}
}
ActiveRecord::Base.establish_connection(:sqlite3)
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :forums, :force => true do |t|
    t.string :name
  end

  create_table :forum_memberships, :force => true do |t|
    t.references :forum
    t.references :user
    t.references :role
  end

  create_table :forum_threads, :force => true do |t|
    t.integer :moderator_id
    t.references :forum
    t.string :name
  end

  create_table :posts, :force => true do |t|
    t.integer :owner_id
    t.references :forum_thread
    t.string :name
  end

  create_table :roles, :force => true do |t|
    t.string :name
    t.text :permissions
  end

  create_table :users, :force => true do |t|
    t.string :name
  end
end

# Configure RSpec to properly integrate with FactoryGirl
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

# Load our Factories
Dir[File.dirname(__FILE__) + '/factory/**/*.rb'].each { |f| require f }