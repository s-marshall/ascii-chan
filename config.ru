require './ascii'
set :database, ENV['DATABASE_URL'] || 'postgres://localhost/[art.db]'
run Sinatra::Application
