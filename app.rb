# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def read_memos
    File.open('memo.json', 'r') do |file|
      data = file.read
      if data == ''
        {}
      else
        JSON.parse(data)
      end
    end
  end

  def save_memos(memos)
    File.open('memo.json', 'w') do |file|
      JSON.dump(memos, file)
    end
  end
end

get '/memo' do
  @memos = read_memos
  erb :index
end

get '/' do
  redirect '/memo'
end

get '/memo/new' do
  erb :new_memo
end

post '/memo/new' do
  @title = params[:title]
  @text = params[:text]
  memos = read_memos
  id = if !memos.empty?
         memos.keys.last.to_i + 1
       else
         0
       end
  memo = { id => { title: @title, text: @text } }
  memos = memos.merge(memo)
  save_memos(memos)
  redirect '/'
end

get '/memo/:id/edit' do |id|
  memos = read_memos
  @title = memos[id]['title']
  @text = memos[id]['text']
  @id = id
  erb :edit_memo
end

patch '/memo/:id/edit' do |id|
  title = params[:title]
  text = params[:text]
  memos = read_memos
  memos[id]['title'] = title
  memos[id]['text'] = text
  save_memos(memos)
  redirect '/'
end

get '/memo/:id' do |id|
  memos = read_memos
  @title = memos[id]['title']
  @text = memos[id]['text']
  @id = id
  erb :show_memo
end

delete '/memo/:id/delete' do |id|
  memos = read_memos
  memos.delete(id)
  save_memos(memos)
  redirect '/'
end
