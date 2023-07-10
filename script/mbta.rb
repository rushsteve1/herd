#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'chronic'
require 'logger'

logger = Logger.new(STDERR)
logger.progname = 'MBTA Alerts'
logger.info 'Running job'

mbta_uri = URI 'https://api-v3.mbta.com/alerts'
kc_uri = URI 'https://knowhere.cafe/api/v1/statuses'
token = ENV['KC_MBTA_TOKEN']
if token.nil? then
    logger.fatal 'KC_MBTA_TOKEN'
    exit 1
end

res = Net::HTTP.get_response mbta_uri
unless res.kind_of? Net::HTTPSuccess then
    logger.fatal 'Fetching error' + res.inspect + res.body
    exit 1
end

fma = Chronic.parse('5 minutes ago')
data = JSON.parse(res.body)['data'] \
           .map{ |a| a['attributes'] } \
           .filter { |a| Chronic.parse(a['updated_at']) > fma } \
           .sort_by { |a| a['updated_at'] }

for alert in data do
    logger.info 'Posting new alert last updated at: ' + alert['updated_at']

    form = "status=" + alert['header']
    headers = { 'Authorization' => "Bearer #{token}" }
    res = Net::HTTP.post(kc_uri, form, headers)

    unless res.kind_of? Net::HTTPSuccess then
        logger.fatal 'Posting error: ' + res.inspect + res.body
        exit 1
    end
end

logger.close