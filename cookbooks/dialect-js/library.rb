require 'chef/dialect'
require 'chef/mixin/convert_to_class_name'

class Chef::Dialect::Javascript < Chef::Dialect
  register_dialect :recipe, '.js', 'text/javascript'
  register_dialect :attributes, '.js', 'text/javascript'

  include Chef::Mixin::ConvertToClassName

  def initialize(run_context)
    super
    install_gem('therubyracer')
    require 'v8'
  end

  def compile_recipe(recipe, filename)
    v8_run(filename, recipe.node) do |ctx|
      each_resource do |res_name|
        ctx[res_name] = lambda do |this, name, *args|
          attrs = v8_to_ruby(args.first)
          recipe.send(res_name, name) do
            # If we got an attrs hash, send them in as method calls
            attrs.each {|key, value| send(key, value)} if attrs
          end
        end
      end
    end
  end

  def compile_attributes(node, filename)
    v8_run(filename, node) do |ctx|
      # default is a keyword in JS/V8
      ctx['default_'] = HashWrapper.new(node.default)
      %w{set normal override default_unless set_unless normal_unless override_unless}.each do |level|
        ctx[level] = HashWrapper.new(node.send(level))
      end
    end
  end

  private

  def v8_run(filename, node=nil, &block)
    ctx = V8::Context.new
    ctx['debug'] = lambda {|this, msg| Chef::Log.debug(msg)}
    ctx['node'] = NodeWrapper.new(node) if node
    block.call(ctx)
    ctx.load(filename)
  end

  def each_resource(&block)
    Chef::Resource.constants.each do |res_class_name|
      res_class = Chef::Resource.const_get(res_class_name)
      next unless res_class.is_a?(Class) && res_class < Chef::Resource
      res_name = convert_to_snake_case(res_class_name.to_s)
      block.call(res_name, res_class)
    end
  end

  def v8_to_ruby(obj)
    if obj.is_a?(V8::Object) || obj.is_a?(Hash)
      obj.inject({}) {|memo, (subkey, subvalue)| memo[v8_to_ruby(subkey)] = v8_to_ruby(subvalue); memo}
    elsif obj.is_a?(Array)
      obj.map{|subvalue| v8_to_ruby(subvalue)}
    else
      obj
    end
  end

  # V8 does special magic things if you inherit from Hash directly that we don't want
  class HashWrapper
    def initialize(inner)
      @inner = inner
    end

    def [](key)
      obj = @inner[key]
      obj = self.class.new(obj) if obj.is_a?(Hash)
      obj
    end

    def []=(key, value)
      @inner[key] = value
    end
  end

  class NodeWrapper < HashWrapper
    extend Forwardable
    def_delegators :@inner, :save

    def default
      HashWrapper.new(@inner.default)
    end

    def normal
      HashWrapper.new(@inner.normal)
    end

    def override
      HashWrapper.new(@inner.override)
    end
  end

end
