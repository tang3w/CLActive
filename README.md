CLActive
========

CLActive help you to build command quickly.

Install CLActive by `gem install clactive`, maybe require super user.

Now, let's build an command called `mary`:

```ruby
#!/usr/bin/env ruby
# mary - Super Mary

require 'rubygems'  # No need if ruby version >= 1.9
require 'clactive'

CLActive do
  option :god, '-g', '--god', 'God mode'
  action { puts "God mode" if god? }
end
```

The code above create an option and an action. We can start god mode:

```bash
$ mary -g  # Or `mary --god`
God mode
```

As you can see, All things will be done in block of CLActive:

```ruby
CLActive do
  # TODO: all work is here
end
```

`option` method create an command option.

`action` method create an command action.

`god?` is a dynamic predicate method create by CLActive.

Dynamic predicate method does not override the method with the same name.

Alternatively, you can recieve options from block:

```ruby
CLActive do
  option :god, '-g', '--god', 'God mode'
  action do |opt|  # User specified options
    puts "God mode" if opt[:god]
  end
end
```

If you like, you can use `opt['god']` instead of `opt[:god]`.

CLActive support sub command:

```ruby
CLActive do
  subcmd :create do
    option :nick, '-n n', '--nick=name', 'Nick of character'
    action { puts "#{nick? || 'Somebody'} is born!" }
  end
end
```

Now, create a Spider Man:

```bash
$ mary create --nick=Spider-Man
Spider-Man is born!
```

If you like, you can also use `name` method to specify command name:

```ruby
CLActive do
  subcmd do
    name :create
    # TODO
  end
end
```

More, you can create nested sub comand:

```ruby
CLActive do
  subcmd :create do
    subcmd :random do
      action { puts '&@^?(^%&*@!' }
    end
  end
end
```

Run the random sub command:

```bash
$ mary create random
&@^?(^%&*@!
```

CLActive also support alias command:

```ruby
CLActive do
  subcmd :create, :new, :cr do
    option :nick, '-n n', '--nick=name', 'Nick of character'
    action { puts "#{nick? || 'Somebody'} is born!" }
  end
end
```

When you create an sub command, the first argument is the name of command.

Alias can be given follow the name. Here, two alias (new and cr) are created:

```bash
$ mary new -n Spider-Man
Spider-Man is born!
$ mary cr -n Spider-Man
Spider-Man is born!
```

You can also use `aka` method to create alias:

```ruby
CLActive do
  subcmd :create do
    aka :new, :cr  # Add two alias
  end
end
```
