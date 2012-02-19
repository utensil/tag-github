ActiveAdmin.register GithubRepository do

  index do
    column("Name", :sortable => :name) {|repos| link_to repos.name, repos.html_url, :target => '_blank' }
    column("Description", :sortable => false) do |repos|
      raw "#{repos.description.html_safe} #{link_to('[home]', repos.homepage_url, :target => '_blank') unless repos.homepage_url.blank? || repos.homepage_url == repos.html_url}"
    end
    column("Language", :language, :sortable => :language)
    #column("") { |repos| link_to 'view', admin_github_repository_path(repos)}
    default_actions
  end

  show :title => :name do
    panel "Repos Info" do
      attributes_table_for github_repository do
        row("Owner") { |repos| repos.owner_account_name}
        row(:description)
        row("Source") { |repos| link_to repos.html_url,  repos.html_url, :target => '_blank' }
        row("Home Page") { |repos| link_to(repos.homepage_url, repos.homepage_url, :target => '_blank') unless repos.homepage_url.blank? || repos.homepage_url == repos.html_url }
        row(:updated_at)
        row(:readme)
      end
    end
  end

  sidebar "Network", :only => :show do
    attributes_table_for github_repository, :fork, :private, :forks, :watchers
  end

  sidebar "Links", :only => :show do
    attributes_table_for github_repository do
      for link in %w[api_url clone_url ssh_url] do
        row(link) { |rep| link_to rep[link], rep[link], :target => '_blank'}
      end
    end
  end
end
