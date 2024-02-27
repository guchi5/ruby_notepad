# ruby_notepad
## 立ち上げ方
1. データベースサーバーの起動
- `sudo /etc/init.d/postgresql start`

2. クローン先のルートディレクトリ内で以下のコマンドを入力
    1. `git switch save_db`
    2. `bundle install`
    3. `bundle exec ruby app.rb`
