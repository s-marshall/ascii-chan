require 'sinatra'
require 'haml'
require 'data_mapper'

DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/artdb')

class Art
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :work_of_art, Text
  property :created, DateTime, :default => Time.now
end

DataMapper.finalize
Art.auto_upgrade!

class FrontMatter
  attr_accessor :title, :art

  def initialize
    @title = ''
    @art = ''
  end
end

def render_front(title = '', artwork = '', error = '')
  art_gallery = Art.all(:order => :created.desc)
  haml :front, :locals => {:title => title, :artwork => artwork, :error => error, :art_gallery => art_gallery}
end

front = FrontMatter.new

get '/' do
  render_front(front.title, front.art, params[:error])
end

post '/' do
  front.title = params[:title]
  front.art = params[:artwork]
  error = ''

  if front.title.length > 0 && front.art.length > 0
    art = Art.create(:title => params[:title], :work_of_art => params[:artwork])
    redirect '/'
  else
    error = 'Add missing title and/or artwork!'
    render_front(params[:title], params[:artwork], error)
  end
end