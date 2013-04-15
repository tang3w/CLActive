CLActive
========

Command line helper for ruby

CLActive help you to build command quickly:

```ruby
# file mary
require 'clactive'

CLActive.option :god, '-g', '--god', 'god mode'
CLActive.option :level, '-l name', '--level=name', 'level number'
CLActive.action do |opt|
  if opt[:level]
    puts "You enter #{opt[:level]} level"
  end
  if opt[:god]
    puts 'You are god now'
  end
end
```

Then, you can start game now:

```
$ mary -g --level=5
You enter 5 level
You are god now
```

An optional command parameter can be given to action block:

```ruby
CLActive.action do |opt, cmd|
  if opt.empty?
    cmd.help
  end
end
```

cmd.help will puts help infomation in standard output.

And you can also create subcommand:

```ruby
CLActive.subcmd :create do |create|
  create.option :name, '-n name', '--nick=name'
  create.action do |opt|
    if opt[:name]
      puts "#{opt[:name]} is born"
    end
  end
end
```

Now, let's create a spider man:

```
$ mary create -n Spider-Man
Spider-Man is born
```

What's more, you can build nest subcommand:

```ruby
CLActive.subcmd :create do |create|
  create.option :name, '-n name', '--nick=name'
  create.action do |opt|
    if opt[:name]
      puts "#{opt[:name]} is born"
    end
  end
  create.subcmd :random do |random|
    random.action do |opt|
      number = 1 + Random.rand(5)
      number.times do
        puts "new character is born"
      end
    end
  end
end
```

Now, you can create random characters:

```
$ mary create random
new character is born
new character is born
new character is born
```
