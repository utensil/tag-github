ActiveAdmin.register GithubRepository do

  scope :all, :default => true
  scope :incomplete do |repos|
    repos.search(:readme_is_blank => true)
  end
  scope :complete do |repos|
    repos.search(:readme_is_blank => false)
  end

  filter :owner_account_name, :label => "Owner"
  filter :name
  filter :language, :as => :select, :collection => proc { GithubRepository.pluck(:language).uniq }
  filter :description
  filter :readme
  filter :homepage_url
  filter :watchers
  filter :forks
  filter :tag_list


  collection_action :delete_all, :method => :delete do
    GithubRepository.delete_all
    redirect_to admin_github_repositories_path
  end

  collection_action :tag, :method => :post do

    params[:github_repository_ids].each do |i|
      rep = GithubRepository.find(i)
      rep.tag_list.add params[:tag_with].split(',')
      rep.save
    end
    logger.info "Github Repository #{params[:github_repository_ids].to_s} tagged with [#{params[:tag_with]}]!"
    flash[:notice] = "GithubRepositories tagged with [#{params[:tag_with]}]!"
    redirect_to :back
  end

  action_item :only => :index do
    link_to "Delete All", delete_all_admin_github_repositories_path, :method => :delete, :confirm => "Are you sure to delete all Github repositories?"
  end

  #menu :label => 'xxx', :parent => "Dashboard"

  index do
    form :method => :post, :action => tag_admin_github_repositories_path do
      #label :for => :tag_with, :class => :label do 'Tag with:' end
      span do
      input :type => :text, :name => :tag_with, :id => :tag_with, :placeholder => 'tags seperated by commas', :width => '50em'
      end
      span do
      input :type => :submit, :value => 'Tag', :name => 'commit'
      end
      input :type => :hidden, :name => :authenticity_token, :id => :authenticity_token, :value => form_authenticity_token
      table_for github_repositories, :paginator=>"true", :class=>"index_table", :id=>"github_repositories" do

        column(check_box_tag("github_repository_ids[]", 'all')) do |repos|
          check_box_tag "github_repository_ids[]", repos.id
        end
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
        column("Tags", :tag_list, :sortable => false)
        column("Operations") do |repos|
          span do
            link_to(image_tag('http://cdn.dustball.com/application_edit.png',:alt => '[edit]', :title => 'edit'), edit_admin_github_repository_path(repos))
          end
          span do
            link_to(image_tag('http://cdn.dustball.com/delete.png',:alt => '[delete]', :title => 'delete'), admin_github_repository_path(repos), :method => :delete, :confirm => "Are you sure to delete Github repository '#{repos.name}'?")
          end
        end
      end
      input :type => :submit, :value => 'Tag', :name => 'commit'
      #methods - Object.new.methods
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
        row("Tags") do |repos|
          unless repos.tag_list.empty?
            repos.tag_list
          end
        end
        row("Readme") do |repos|
          unless repos.readme.blank?
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
