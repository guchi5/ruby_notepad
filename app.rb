# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  @memos = File.open('memo.json', 'r') do |file|
    data = file.read
    if data == ''
      {}
    else
      JSON.parse(data)
    end
  end

  erb :index
end

get '/new' do
  erb :new_memo
end

post '/save' do
  @title = h(params[:title])
  @text = h(params[:text])
  memos = File.open('memo.json', 'r') do |file|
    data = file.read
    if data == ''
      JSON.parse('{}')
    else
      JSON.parse(data)
    end
  end

  id = if !memos.empty?
         memos.keys.last.to_i + 1
       else
         0
       end
  memo = { id => { title: @title, text: @text } }
  memos = memos.merge(memo)
  File.open('memo.json', 'w') do |file|
    JSON.dump(memos, file)
  end
  redirect '/'
end

get '/edit/:id' do |id|
  memos = File.open('memo.json', 'r') do |file|
    data = file.read
    JSON.parse(data)
  end
  @title = memos[id]['title']
  @text = memos[id]['text']
  @id = id
  erb :edit_memo
end

patch '/edit/:id' do |id|
  title = h(params[:title])
  text = h(params[:text])
  memos = File.open('memo.json', 'r') do |file|
    data = file.read
    JSON.parse(data)
  end
  memos[id]['title'] = title
  memos[id]['text'] = text
  File.open('memo.json', 'w') do |file|
    JSON.dump(memos, file)
  end
  redirect '/'
end

get '/show/:id' do |id|
  memos = File.open('memo.json', 'r') do |file|
    data = file.read
    JSON.parse(data)
  end
  @title = memos[id]['title']
  @text = memos[id]['text']
  @id = id
  erb :show_memo
end

delete '/delete/:id' do |id|
  memos = File.open('memo.json', 'r') do |file|
    data = file.read
    JSON.parse(data)
  end
  memos.delete(id)
  File.open('memo.json', 'w') do |file|
    JSON.dump(memos, file)
  end
  redirect '/'
end
