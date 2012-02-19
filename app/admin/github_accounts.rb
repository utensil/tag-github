ActiveAdmin.register GithubAccount do
  form do |f|
    f.inputs do
      f.input :login_name
    end
    f.buttons
  end

  index :as => :grid do |acc|
    div do
      h4 acc.login_name
      a :href => admin_github_account_path(acc) do
        image_tag(acc.avatar_url, :size => '80x80', :alt => acc.login_name)
      end
    end
  end

  show do
    panel "User Info" do
      if github_account.avatar_url
        div do
          a :href => github_account.html_url do
            image_tag github_account.avatar_url
          end
        end
      end
      attributes_table_for github_account do
        row(:login_name)
        row(:registed_at)
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
