actions :install, :remove, :upgrade

attribute :package, :kind_of => String, :name_attribute => true
attribute :source, :kind_of => String
attribute :version, :kind_of => String
attribute :args, :kind_of => String
attribute :params, :default=>""
attribute :version_info, :default=>""
attribute :installed_version, :default=>""

def initialize(*args)
  super
  @action = :install
end

attr_accessor :exists, :upgradeable, :installed
