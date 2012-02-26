ActiveAdmin.register GithubRepository do

  filter :owner_account_name, :label => "Owner"
  filter :name
  filter :language, :as => :select, :collection => proc { GithubRepository.pluck(:language).uniq }
  filter :description
  filter :readme
  filter :homepage_url
  filter :watchers
  filter :forks

  collection_action :delete_all, :method => :delete do
    GithubRepository.delete_all
    redirect_to admin_github_repositories_path
  end

  action_item :only => :index do
    link_to "Delete All", delete_all_admin_github_repositories_path, :method => :delete, :confirm => "Are you sure to delete all Github repositories?"
  end

  #menu :label => 'xxx', :parent => "Dashboard"

  index do
    column("Name", :sortable => :name) do |repos|
      span do
        link_to repos.name, admin_github_repository_path(repos), :target => '_blank'
      end
      span do
        link_to(image_tag('http://cdn.dustball.com/lightbulb.png', :alt => '[source]', :title => 'source'), repos.html_url, :target => '_blank')
      end
    end
    column("Description", :sortable => false) do |repos|
      span { repos.description }
      unless repos.homepage_url.blank? || repos.homepage_url == repos.html_url
        span do
          link_to(image_tag('http://cdn.dustball.com/house.png', :alt => '[home]', :title => 'home'), repos.homepage_url, :target => '_blank')
        end
      end
    end
    column("Language", :language, :sortable => :language)
    column("Operations") do |repos|
      span do
        link_to(image_tag('http://cdn.dustball.com/application_edit.png',:alt => '[edit]', :title => 'edit'), edit_admin_github_repository_path(repos))
      end
      span do
        link_to(image_tag('http://cdn.dustball.com/delete.png',:alt => '[delete]', :title => 'delete'), admin_github_repository_path(repos), :method => :delete, :confirm => "Are you sure to delete Github repository '#{repos.name}'?")
      end
    end
  end

  show :title => :name do
    panel "Repos Info" do
      attributes_table_for github_repository do
        row("Owner") { |repos| repos.owner_account_name}
        row(:description)
        row("Source") { |repos| link_to repos.html_url,  repos.html_url, :target => '_blank' }
        row("Home Page") { |repos| link_to(repos.homepage_url, repos.homepage_url, :target => '_blank') unless repos.homepage_url.blank? || repos.homepage_url == repos.html_url }
        row(:updated_at)
        row("Readme") do |repos|
          if repos.readme.nil?
                nil
          else
            div :style => 'height: 500px; overflow:scroll' do
            #TODO safe?
              raw repos.readme
            end
          end
        end
      end
    end

    if github_repository.watched_accounts.size > 0
      panel "Watched Accounts" do
          table_for(github_repository.watched_accounts) do
            column("Account Name") {|acc| link_to acc.login_name, admin_github_account_url(acc), :target => '_blank' }
            column("Registered Since", :registed_at)
          end
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
