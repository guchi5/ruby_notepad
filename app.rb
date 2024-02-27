# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

class DatabaseManager
  def initialize
    @conn = PG.connect(dbname: 'postgres')
    @conn.exec('CREATE TABLE IF NOT EXISTS memos (id serial, title varchar(255), content text)')
  end

  def read_memos
    @conn.exec('SELECT * FROM memos')
  end

  def read_memo_by_id(id)
    @conn.exec('SELECT * FROM memos WHERE id = $1', [id])[0]
  end

  def add_memo(memo)
    @conn.exec('INSERT INTO memos (title, content) VALUES ($1, $2)', [memo[:title], memo[:content]])
  end

  def update_memo(memo)
    @conn.exec('UPDATE memos SET title = $1, content = $2 WHERE id = $3', [memo[:title], memo[:content], memo[:id]])
  end

  def delete_memo(id)
    @conn.exec('DELETE FROM memos WHERE id = $1', [id])
  end
end

db = DatabaseManager.new

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/memos' do
  @memos = db.read_memos
  erb :index
end

get '/' do
  redirect '/memos'
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  @title = params[:title]
  @content = params[:content]
  memo = { title: @title, content: @content }
  db.add_memo(memo)
  redirect '/'
end

get '/memos/:id/edit' do |id|
  memo = db.read_memo_by_id(id)
  @title = memo['title']
  @content = memo['content']
  @id = id
  erb :edit_memo
end

patch '/memos/:id' do |id|
  title = params[:title]
  content = params[:content]
  db.update_memo({ id:, title:, content: })
  redirect '/'
end

get '/memos/:id' do |id|
  memo = db.read_memo_by_id(id)
  @title = memo['title']
  @content = memo['content']
  @id = id
  erb :show_memo
end

delete '/memos/:id' do |id|
  db.delete_memo(id)
  redirect '/'
end
