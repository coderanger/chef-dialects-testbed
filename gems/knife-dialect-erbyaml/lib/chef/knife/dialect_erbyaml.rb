require 'chef/dialect/yaml'
require 'chef/mixin/template'

class Chef::Dialect::ErbYaml < Chef::Dialect::Yaml
  register_dialect :role, '.yaml', 'text/yaml', 1
  register_dialect :role, '.yml', 'text/yaml', 1

  include Chef::Mixin::Template

  private

  def parse_data(data, filename)
    context = TemplateContext.new
    data = context.render_template_from_string(data)
    super(data, filename)
  end
end
