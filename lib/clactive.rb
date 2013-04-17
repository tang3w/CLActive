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
    start = cmd

    until args.empty?
      begin
        cmd.parse(args)
      rescue OptionParser::ParseError => e
        puts e.message
        return
      end

      break unless name = args.shift

      unless subcmd = cmd[name]
        puts "invalid option: " << name
        return
      end

      cmd.subcmd = subcmd
      cmd = subcmd
    end

    start.run
  end

  klass_subcmd = Class.new do
    attr_reader :options
    attr_reader :subcmds

    define_method :initialize do
      @options = {}.extend(tos)
      @subcmds = {}.extend(tos)
      @usropts = {}.extend(tos)
      @parser = OptionParser.new
    end

    def name(key = nil)
      key ? (@name = key.to_s) : @name
    end

    def symbol
      name.to_sym if name
    end

    def parse(args)
      @parser.order!(args)
    end

    def help
      @parser.help
    end

    def run
      if @action
        argv = []
        argv << @usropts if @action.arity != 0
        self.instance_exec(*argv, &@action)
        subcmd.run if subcmd
      end
    end

    def subcmd=(cmd)
      @subcmd = cmd
    end

    def [](key)
      cmd = subcmds[key]
      unless cmd
        key = key.to_s
        subcmds.reverse_each do |_, val|
          return val if val.aka.include?(key)
        end
      end
      cmd
    end

    def subcmd(*keys, &block)
      if block
        cmd = self.class.new
        unless keys.empty?
          keys.map!(&:to_s)
          cmd.name(keys.shift)
          cmd.aka.concat(keys) unless keys.empty?
        end
        cmd.instance_exec(&block)
        subcmds[cmd.name] = cmd if cmd.name
      else
        @subcmd
      end
    end

    def option(key, *argv)
      unless argv.empty?
        @options[key] = argv
        @parser.on(*argv) do |val|
          @usropts[key] = val
        end

        meth = key.to_s + '?'
        if meth.to_sym.inspect !~ /[@$"]/ && !respond_to?(meth, true)
          eigen = class << self; self end
          eigen.send(:define_method, meth) do
            @usropts[key]
          end
        end
      end
    end

    def action(&block)
      @action = block if block
    end

    def aka(key = nil)
      if key
        key = key.to_s
        aka << key unless aka.include?(key)
      else
        @aka ||= []
      end
    end
  end

  apis = %w(name subcmd option action)
  eigen = class << self; self end
  cmd = klass_subcmd.new

  cmd.name File::basename($0, '.*')

  apis.each do |api|
    eigen.send(:define_method, api) do |*args, &block|
      cmd.send(api, *args, &block)
    end
  end

  at_exit do
    parser.call(cmd, ARGV.dup)
  end
end

def CLActive(&block)
  CLActive.instance_exec(&block) if block
end
