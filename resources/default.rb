actions :install, :remove, :upgrade

attribute :package, :kind_of => String, :name_attribute => true
attribute :source, :kind_of => String
attribute :version, :kind_of => String
attribute :args, :kind_of => String
attribute :other_args, :kind_of => String
attribute :choco_params, :kind_of => String, :default=>nil
attribute :version_info, :default=>""
attribute :installed_version, :default=>""
attribute :force, :kind_of => [TrueClass, FalseClass], :default=>false
attribute :x86, :kind_of => [TrueClass, FalseClass], :default=>false

def initialize(*args)
  super
  @action = :install
end

attr_accessor :exists, :upgradeable, :installed
