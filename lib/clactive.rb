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

  parser = lambda do |cmd, args|
    queue = [cmd]

    until args.empty?
      begin
        subcmds = cmd.parse(args)
      rescue OptionParser::ParseError => e
        puts e.message
        return
      end

      break unless name = args.shift

      unless cmd = subcmds[name]
        puts "invalid option: " << name
        return
      end

      queue << cmd
    end

    queue.each(&:run)
  end

  klass_subcmd = Class.new do
    define_method :initialize do
      @subcmds = {}.extend(tos)
      @usropts = {}.extend(tos)
      @parser = OptionParser.new
    end

    def parse(args)
      @parser.order!(args)
      @subcmds
    end

    def help
      puts @parser.help
    end

    def run
      if @action
        argv = [@usropts]
        argc = @action.arity
        argv << self if argc > 1 || argc < 0
        @action.call(*argv)
      end
    end

    def subcmd(name)
      if block_given?
        yield cmd = self.class.new
        @subcmds[name] = cmd
      end
      self
    end

    def option(name, *argv)
      @parser.on(*argv) do |val|
        @usropts[name] = val
      end
      self
    end

    def action(&block)
      @action = block if block
      self
    end
  end

  apis = [:subcmd, :option, :action]
  eigen = class << self; self end
  cmd = klass_subcmd.new

  apis.each do |api|
    eigen.send(:define_method, api) do |*args, &block|
      cmd.send(api, *args, &block)
    end
  end

  at_exit do
    parser.call(cmd, ARGV.dup)
  end
end
