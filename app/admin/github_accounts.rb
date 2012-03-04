ActiveAdmin.register GithubAccount do

  scope :all, :default => true
  scope :user do |accs|
    accs.where(:type => 'GithubUser')
  end

  scope :organization do |accs|
    accs.where(:type => 'GithubOrg')
  end

  filter :login_name
  filter :registed_at, :label => "Registered Since"

  form do |f|
    f.inputs do
      f.input :login_name
    end
    f.buttons
  end

  member_action :update_repos, :method => :post do

    GithubAccount.find(params[:id]).try(:async_pull_info)

    redirect_to :back
  end

  action_item :only => :show do
    link_to "Update Watched Repositories", update_repos_admin_github_account_path(github_account), :method => :post
  end

  index :as => :grid do |acc|
    div do
      h4 acc.login_name
      a :href => admin_github_account_path(acc) do
        image_tag(acc.avatar_url, :size => '80x80', :alt => acc.login_name)
      end
      div do
        span do
          link_to image_tag('http://cdn.dustball.com/user_edit.png',:alt => '[delete]', :title => 'delete'), edit_admin_github_account_path(acc)
        end
        span do
          link_to image_tag('http://cdn.dustball.com/user_delete.png',:alt => '[delete]', :title => 'delete'), admin_github_account_path(acc), :method => 'delete', :confirm => "Are you sure to delete Github account '#{acc.login_name}'?"
        end
      end
    end
  end

  show :title => :login_name do
    panel "Account Info" do
      if github_account.avatar_url
        div do
          a :href => github_account.html_url do
            image_tag github_account.avatar_url
          end
        end
      end
      attributes_table_for github_account do
        row("Account Type") { |acc| acc.type.nil? ? nil : (acc.type == 'GithubUser' ?
        'User' : 'Organization') }
        row("Registered Since") { |acc| acc.registed_at }
        row("Watched Repositories") { |acc| acc.watched_repositories.size }
      end
    end
    if github_account.watched_repositories.size > 0
      panel "Watched Repositories" do
          table_for(github_account.watched_repositories) do
            column(:name, :sortable => :name) {|repos| link_to repos.name, admin_github_repository_url(repos), :target => '_blank' }
            column(:description)
            column(:language, :sortable => :language)
          end
      end
    end
  end

  sidebar "Activities", :only => :show do
    attributes_table_for github_account, :following, :followers, :public_repos, :public_gists
  end

end
