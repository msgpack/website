# encoding: utf-8
require 'rest-client'
require 'json'
require 'cgi'
require 'time'
require 'nokogiri'
#require 'github/markup'
require 'erb'

here = File.dirname(__FILE__)

REPO_DESC_MATCH = /msgpack\.org\[([^\]]+)\]/

DOC_FILES = %w[msgpack.org.md README.md README.markdown README.rdoc README.rst README]

def github_search(keyword, &callback)
  url = "https://api.github.com/legacy/repos/search/#{CGI.escape(keyword)}"
  page = 1
  while true
    js = RestClient.get(url, :params=>{'start_page'=>page})
    repos = JSON.parse(js)['repositories']
    break if repos.empty?
    repos.each(&callback)
    page += 1
  end
end

def get_quickstart_html(repo_url)
  DOC_FILES.each {|fname|
    begin
      if fname.include?('.')
        url = "#{repo_url}/blob/master/#{fname}"
        data = RestClient.get(url)
        begin
          html = Nokogiri::HTML::Document.parse(data, url, 'UTF-8').css('.file')[0].xpath('div').last.to_s
        rescue
          break  # fail & skip
        end

      else
        raw_url = repo_url.sub('github.com', 'raw.github.com')
        data = RestClient.get("#{raw_url}/master/#{fname}")
        html = "<pre>#{CGI.escape_html(data)}</pre>"
      end

      return html, fname
    rescue RestClient::ResourceNotFound
      # do nothing
    end
  }

  return nil
end

def tweak_quickstart_html(html)
  html.gsub!(/<(\/?)h4/, "<\\1h8")
  html.gsub!(/<(\/?)h3/, "<\\1h7")
  html.gsub!(/<(\/?)h2/, "<\\1h6")
  html.gsub!(/<(\/?)h1/, "<\\1h5")
  html
end

Repo = Struct.new(:url, :homepage, :created_at, :html)

repos = []

github_search('msgpack.org') do |repo|
  # description needs to include msgpack[LANG]
  m = REPO_DESC_MATCH.match(repo['description'])
  next unless m
  repo['lang'] = CGI.escape_html(m[1])

  # skip forked repos
  next if repo['fork']

  url = repo['url']

  homepage = repo['homepage']
  homepage = nil if homepage == url
  homepage = nil if homepage =~ /\Ahttp\:\/\/msgpack.org\/?/
  repo['homepage'] = homepage

  html, fname = get_quickstart_html(url)
  next unless html

  html = tweak_quickstart_html(html)
  repo['quickstart_html'] = html
  repo['quickstart_fname'] = fname

  repo['id'] = "#{repo['owner']}-#{repo['name']}".gsub(/[^a-zA-Z0-9_\-]+/,'-')

  repos << repo
end

@repos = repos.sort_by {|repo| Time.parse(repo['created_at']) }

html = ERB.new(File.read("#{here}/index.html.erb")).result

orig = File.read("#{here}/index.html") rescue nil

if orig != html
  File.open("#{here}/index.html", 'w') {|f| f.write html }
end

