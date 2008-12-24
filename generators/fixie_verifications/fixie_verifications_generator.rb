class FixieVerificationsGenerator < Rails::Generator::NamedBase
  def manifest    
    record do |m|
      m.migration_template "migration.rb",
                           File.join('db', 'migrate'),
                           :migration_file_name => "add_fixie_verifications"
    end
  end 
 
end
