require 'optparse'

module CLActive
  tos = Module.new do
    def [](key)
      self.fetch(key.to_s, nil)
    end

    def []=(key, value)
      self.store(key.to_s, value)
    end
  end

  parser = ->(cmd, args) do
    queue = []

    until args.empty?
      begin
        subcmds = cmd.parse(args)
      rescue OptionParser::ParseError => e
        puts e.message
        return
      end

      queue << cmd
      break unless name = args.shift

      unless cmd = subcmds[name]
        puts "invalid option: " << name
        return
      end
    end

    queue.each(&:run)
  end

  klass_subcmd = Class.new do
    define_method :initialize do
      @options = {}.extend(tos)
      @subcmds = {}.extend(tos)
      @usropts = {}.extend(tos)
    end

    def parse(args)
      OptionParser.new do |opt|
        @options.each do |key, argv|
          opt.on(*argv) do |val|
            @usropts[key] = val
          end
        end
      end.order!(args)
      @subcmds
    end

    def run
      @action.call(@usropts) if @action
    end

    def subcmd(name)
      if block_given?
        yield cmd = self.class.new
        @subcmds[name] = cmd
      end
      self
    end

    def option(name, *argv)
      @options[name] = argv if argv
      self
    end

    def action(&block)
      @action = block if block
      self
    end
  end

  klass_delegate = Class.new do
    attr_reader :cmd

    define_method :initialize do
      @args = ARGV.dup
      @cmd = klass_subcmd.new

      at_exit do
        parser.call(@cmd, @args.dup)
      end
    end
  end

  delegate = klass_delegate.new

  self.instance_eval do
    [:subcmd, :option, :action].each do |api|
      define_singleton_method api do |*args, &block|
        delegate.cmd.send(api, *args, &block)
      end
    end
  end
end
