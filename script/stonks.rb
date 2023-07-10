#!/usr/bin/env ruby

require 'net/http'
require 'nokogiri'
require 'logger'

logger = Logger.new(STDERR)
logger.progname = 'Daily Stonks'
logger.info 'Running job'

yf_uri = URI 'https://finance.yahoo.com'
kc_uri = URI 'https://knowhere.cafe/api/v1/statuses'
token = ENV['KC_STONKS_TOKEN']
if token.nil? then
    logger.fatal 'Missing token KC_STONKS_TOKEN'
    exit 1
end

res = Net::HTTP.get_response yf_uri
unless res.kind_of? Net::HTTPSuccess then
    log.fatal res
    exit 1
end

doc = Nokogiri::HTML5 res.body
el = doc.css('fin-streamer')[5]

if el.nil? then
    logger.fatal 'Yahoo Finance CSS selector failed'
    exit 1
end

emoji = '📈'
if el.text.chars.first == '-' then
    emoji = '📉'
end

form = "status=" + emoji
headers = { 'Authorization' => "Bearer #{token}" }
res = Net::HTTP.post(kc_uri, form, headers)
unless res.kind_of? Net::HTTPSuccess then
    logger.fatal 'Posting error: ' + res.inspect + res.body
    exit 1
end

logger.close