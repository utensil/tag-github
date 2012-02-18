ActiveAdmin.register GithubAccount do
  show do
    panel "User Info" do
      attributes_table_for github_account, :login_name, :registed_at
    end

    panel "Watched Repositories" do
      table_for(github_account.watched_repositories) do
        column("Name") {|repos| repos.name}
        column("Html Url") {|repos| link_to repos.html_url, repos.html_url}
      end
    end
  end

  sidebar "Activities", :only => :show do
    attributes_table_for github_account, :following, :followers, :public_repos, :public_gists
  end
end
