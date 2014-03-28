require 'rest_client'
require 'json'
require 'yaml'

namespace :slack do
  task :finish do
    path = File.expand_path 'config/slack.yml', Bundler.root
    if File.exist? path
      config = YAML.load_file(path)[rails_env]

      payload = config['payload']
      token = ENV['slack_token'] || config['token']

      exit if token.nil?

      hook_url = config['hook_url'] + token

      revision = `git rev-parse --short #{branch}`.strip
      msg = `git log -1 --pretty=%B #{branch}`.strip

      repo_url = repository.rpartition('.').first
      branch_url = "#{repo_url}/tree/#{branch}"
      revision_url = "#{repo_url}/commit/#{revision}"

      payload['text'] ||= <<-EOS
        Deployed <#{branch_url}|#{branch}> to #{domain}
        Current revision is <#{revision_url}|#{revision}>
        ------------------------------
        #{msg}
      EOS
      RestClient.post hook_url, payload: payload.to_json
    end
  end
end
