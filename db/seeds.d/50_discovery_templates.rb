kind = TemplateKind.unscoped.where(:name => 'kexec').first_or_create
organizations = Organization.unscoped.all
locations = Location.unscoped.all

ProvisioningTemplate.without_auditing do
  [['redhat_kexec.erb', 'Red Hat'], ['debian_kexec.erb', 'Debian']].each do |tmpl_names|
    content = File.read(File.join(ForemanDiscovery::Engine.root, 'app', 'views', 'foreman_discovery', tmpl_names[0]))
    tmpl = ProvisioningTemplate.unscoped.where(:name => "Discovery #{tmpl_names[1]} kexec").first_or_create(
      :template_kind_id => kind.id,
      :snippet => false,
      :template => content
    )
    tmpl.attributes = {
      :template => content,
      :default  => true,
      :vendor   => "Foreman Discovery",
      :locked   => true
    }
    tmpl.organizations = organizations if SETTINGS[:organizations_enabled]
    tmpl.locations = locations if SETTINGS[:locations_enabled]
    tmpl.save!(:validate => false) if tmpl.changes.present?
  end
end
