namespace :sync do

  desc 'Copy common models and tests from Master'
  task :copy do
    source_path = '../ankaa-model'
    dest_path = '.'

    # Copy all models & tests
    %x{cp #{source_path}/app/models/*.rb #{dest_path}/app/models/}
    %x{cp #{source_path}/app/models/concerns/*.rb #{dest_path}/app/models/concerns/}

  end
end