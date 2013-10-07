require 'chef/dialect/json'

class Chef::Dialect::JsonAttributes < Chef::Dialect::Json
  register_dialect :attributes, '.json', 'application/json'
end
