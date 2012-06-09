require "bundler/setup"
require "sinatra"
require "sinatra/reloader" if development?
require 'linode'

get '/:api_key?' do
  if params[:api_key]
    l = Linode.new(api_key: params[:api_key])
    @domains = "Click the domain you want to add Google DNS records to <ul>"
    l.domain.list.each do |domain|
      @domains << "<li><a href='/update/#{params[:api_key]}/#{domain.domainid}/#{domain.domain}'>#{domain.domain}</a></li>"
    end
    return @domains += "</ul> Note: I take no responsibility for any issues that might arise from this. Make sure you backup your DNS first if you want to be safe!"
  else
    "Get your API key from here <a href='https://manager.linode.com/profile/index#apikey'>https://manager.linode.com/profile/index</a>, then visit #{request.base_url}/[API-KEY]"
  end
end

get '/update/:api_key/:domainid/:domain' do
  l = Linode.new(api_key: params[:api_key])
  records = [
    ['ASPMX.L.GOOGLE.COM', 1],
    ['ALT1.ASPMX.L.GOOGLE.COM', 5],
    ['ALT2.ASPMX.L.GOOGLE.COM', 5],
    ['ASPMX2.GOOGLEMAIL.COM', 10],
    ['ASPMX3.GOOGLEMAIL.COM', 10]
  ]
  records.each do |record|
    begin
      l.domain.resource.create(
        domainid: params['domainid'],
        type: 'MX',
        target: record[0],
        priority: record[1]
      )
    rescue
      'error'
    end
  end

  "DNS Records Updated for <a href='https://manager.linode.com/dns/domain/#{params[:domain]}'>#{params[:domain]}</a>"
end