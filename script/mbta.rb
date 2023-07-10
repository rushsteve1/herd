#!/usr/bin/env ruby

require 'net/http'
require 'json'

mbta_uri = URI 'https://api-v3.mbta.com/alerts'
kc_uri = URI 'https://knowhere.cafe/api/v1/statuses'
token = ENV['KC_MBTA_TOKEN']
if token.nil? then
    exit 1
end

res = Net::HTTP.get_response mbta_uri
unless res.kind_of? Net::HTTPSuccess then
    exit 1
end

data = JSON.parse(res.body)['data']

for alert in data do
    a = alert['attributes']
    form = "status=#{a['header'] + (a['description'] || '')}"
    headers = { 'Authorization' => "Bearer #{token}" }
    res = Net::HTTP.post(kc_uri, form, headers)

    unless res.kind_of? Net::HTTPSuccess then
        exit 1
    end
end