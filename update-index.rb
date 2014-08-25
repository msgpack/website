# encoding: utf-8
require 'octokit'
require 'uri'
require 'httpclient'
require 'faraday'
require 'time'
require 'cgi'
require 'nokogiri'
#require 'github/markup'
require 'git'
require 'erb'
require 'logger'
require 'parallel'

class IndexHtmlRenderer
  REPO_DESCRIPTION_MATCH = /msgpack\.org\[([^\]]+)\]/
  QUICKSTART_FILES = %w[msgpack.org.md README.md README.markdown README.rdoc README.rst README]

  def search_github_repos
    @log.info "Searching msgpack repositories from github..."
    Parallel.map(octokit_search_repos("msgpack.org"), in_threads: 8) do |repo|
      github_com = Faraday.new('https://github.com')
      github_com_raw = Faraday.new('https://raw.github.com')
      github_com.headers = github_com_raw.headers = {
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      }

      @log.info "  < #{repo[:full_name]}"

      # skip forked repos
      next if repo[:fork]

      # description needs to include msgpack[LANG]
      desc_match = REPO_DESCRIPTION_MATCH.match repo[:description]
      next unless desc_match
      lang = CGI.escape_html(desc_match[1])

      quickstart_html, quickstart_fname = get_quickstart_html(github_com, github_com_raw, repo)
      next unless quickstart_html
      tweak_quickstart_html!(quickstart_html)

      repo_id = repo[:full_name].gsub(/[^a-zA-Z0-9_\-]+/,'-')

      homepage = repo[:homepage]
      homepage = nil if homepage =~ /^http\:\/\/msgpack.org\/?/
      homepage = nil if homepage == ""
      homepage ||= repo[:html_url]

      @log.info "  >> #{repo[:full_name]}: lang=#{lang}, quickstart_file=#{quickstart_fname}"

      {
        msgpack_lang: lang,
        msgpack_quickstart_html: quickstart_html,
        msgpack_repo_id: repo_id,
        msgpack_repo_homepage: homepage,
      }.merge(repo)
    end.compact
  end

  def get_quickstart_html(github_com, github_com_raw, repo)
    QUICKSTART_FILES.each {|fname|
      if fname.include?('.')
        path = "#{repo[:full_name]}/blob/master/#{fname}"
        res = github_com.get(path)
        next if res.status != 200

        begin
          url = github_com.build_url(path).to_s
          html = Nokogiri::HTML::Document.parse(res.body, url, 'UTF-8').css('.file')[0].xpath('div').last.to_s
        rescue
          log.error "Failed to parse quickstart file #{repo[:full_name]}/#{fname}: #{$!}"
          break  # fail & skip
        end

      else
        path = "#{repo[:full_name]}/master/#{fname}"
        res = github_com_raw.get(path)
        next if res.status != 200

        html = "<pre>#{CGI.escape_html(res.body)}</pre>"
      end

      return html, fname
    }

    return nil
  end

  private :search_github_repos, :get_quickstart_html

  def initialize(log, github_token)
    @log = log
    @github = Octokit::Client.new(access_token: github_token)
  end

  def render(erb)
    # older repository first for deterministic display
    repos = search_github_repos.sort_by {|repo| repo[:created_at] }
    return ERB.new(File.read(erb)).result(binding)
  end

  private

  def tweak_quickstart_html!(html)
    html.gsub!(/<(\/?)h4/, "<\\1h8")
    html.gsub!(/<(\/?)h3/, "<\\1h7")
    html.gsub!(/<(\/?)h2/, "<\\1h6")
    html.gsub!(/<(\/?)h1/, "<\\1h5")
    html
  end

  def octokit_search_repos(keyword, &block)
    items = []

    page = 1
    loop do
      res = @github.search_repos("msgpack.org", page: page)
      break if res.items.empty?
      items.concat res.items
      page += 1
    end

    items
  end
end

def update_index(log)
  # setup ssh
  ssh_config_path = "#{ENV['HOME']}/.ssh/config"
  FileUtils.mkdir_p File.dirname(ssh_config_path)
  ssh_config = File.read(ssh_config_path) rescue ""
  unless ssh_config =~ /github_msgpack_website/
    File.open("#{ENV['HOME']}/.ssh/config", "a") {|f|
      f.write <<-EOF
Host github_msgpack_website
  HostName github.com:msgpack/website.git
  User git
  IdentityFile ~/.ssh/github_msgpack_website_id
      EOF
    }
  end
  File.open("#{ENV['HOME']}/.ssh/github_msgpack_website_id", "w", 0600) {|f|
    f.write ENV['GITHUB_DEPLOY_KEY']
  }

  website_repo = "github_msgpack_website:msgpack/website.git"

  # octokit config
  github_token = ENV['GITHUB_TOKEN']
  Faraday.default_adapter = :httpclient

  # clone repository
  repo_dir = File.expand_path("tmp/website")

  retry_count = 0
  begin
    File.open('index.html.erb') do |f|
      f.flock(File::LOCK_EX)
    end

    if Dir.exists?(repo_dir)
      log.info "Using cached local git repository..."
      git = Git.open(repo_dir)
    else
      log.info "Cloning remote git repository..."
      FileUtils.mkdir_p(repo_dir)
      git = Git.clone(website_repo, File.basename(repo_dir),
                      path: File.dirname(repo_dir))
    end

    log.info "Merging the latest files..."
    log.info git.branch("gh-pages").checkout
    log.info git.remote("origin").fetch
    log.info git.remote("origin").merge("gh-pages")
    prev_commit = git.object('HEAD').sha

    log.info git.remote("origin").merge("master")

    up = IndexHtmlRenderer.new(log, github_token)
    html = up.render(File.join(".", "index.html.erb"))
    orig = File.read(File.join(repo_dir, "index.html")) rescue ""

    if html != orig
      File.write(File.join(repo_dir, "index.html"), html)

      git.config("user.name", "msgpck.org updator on heroku")
      git.config("user.email", "frsyuki@users.sourceforge.jp")

      git.add(File.join(repo_dir, "index.html"))
      git.commit("updated index.html")
    end

    next_commit = git.object('HEAD').sha
    if prev_commit == next_commit
      log.info "Not changed."
    else
      log.info "Pushing changes to remote repository..."
      log.info git.push("origin", "gh-pages")
    end

    log.info "Done."

  rescue
    raise if retry_count >= 1

    # delete repo_dir and retry
    FileUtils.rm_rf repo_dir
    FileUtils.mkdir_p File.dirname(repo_dir)
    retry_count += 1
    retry
  end
end

update_index(Logger.new(STDOUT)) if __FILE__ == $0

