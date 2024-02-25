# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def read_memos
    conn = PG.connect(dbname: 'postgres')
    result = conn.exec("SELECT * FROM information_schema.tables WHERE table_name = 'memos'")
    conn.exec('CREATE TABLE memos (id serial, title varchar(255), content text)') if result.values.empty?
    conn.exec('SELECT * FROM memos')
  end

  def read_memo_by_id(id)
    conn = PG.connect(dbname: 'postgres')
    conn.exec("SELECT * FROM memos WHERE id = #{id}")
  end

  def add_memo(memo)
    conn = PG.connect(dbname: 'postgres')
    conn.exec("INSERT INTO memos (title, content) VALUES ('#{memo[:title]}', '#{memo[:text]}')")
  end

  def update_memo(memo)
    conn = PG.connect(dbname: 'postgres')
    conn.exec("UPDATE memos SET title = '#{memo[:title]}', content = '#{memo[:text]}' WHERE id = #{memo[:id]}")
  end

  def delete_memo(id)
    conn = PG.connect(dbname: 'postgres')
    conn.exec("DELETE FROM memos WHERE id = #{id}")
  end
end

get '/memos' do
  @memos = read_memos
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
  @text = params[:text]
  memo = { title: @title, text: @text }
  add_memo(memo)
  redirect '/'
end

get '/memos/:id/edit' do |id|
  memo = read_memo_by_id(id)
  @title = memo[0]['title']
  @text = memo[0]['content']
  @id = id
  erb :edit_memo
end

patch '/memos/:id' do |id|
  title = params[:title]
  text = params[:text]
  update_memo({ id:, title:, text: })
  redirect '/'
end

get '/memos/:id' do |id|
  memo = read_memo_by_id(id)
  @title = memo[0]['title']
  @text = memo[0]['content']
  @id = id
  erb :show_memo
end

delete '/memos/:id' do |id|
  delete_memo(id)
  redirect '/'
end
