#! /usr/bin/env ruby
# frozen_string_literal: true

require 'erb'
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'yaml'

require 'dotenv/load'

URL = ARGV.first

exit if URL.nil?

module Wordpress
  class Meet
    attr_reader :day, :month, :year

    def initialize(uri)
      @uri = uri
      _, @year, @month, @day, = uri.path.split('/')
    end

    def content
      @content ||= @uri.open.read
    end

    def document
      @document ||= Nokogiri::HTML(content)
    end

    def from_date
      Date.new(@year.to_i, @month.to_i, @day.to_i)
    end

    def sections
      []
    end
  end
end

module NewSite
  class MeetReport
    TEMPLATE = <<~TEMPLATE
      <%= front_matter.to_yaml %>
      ---
      <%= content.to_s %>
    TEMPLATE

    def initialize(wp_meet)
      @wp_meet = wp_meet
    end

    def markdown
      ERB.new(TEMPLATE).result(binding)
    end

    def front_matter
      {
        from: @wp_meet.from_date.strftime('%F'),
        to: (@wp_meet.from_date + 2).strftime('%F'),
        hut: 'todo',
        area: 'todo',
        members: %w[him her them],
        guests: [],
        cover_image: 'https://pub-03bee428a70844da892636a1cd0420de.r2.dev/dev/assets/2022/05/13/ardvillin-ardgour/01.jpeg',
        preamble: "Mary had a little lamb.\nIts fleece was white as snow."
      }
    end

    def content
      "And everywhere that Mary went,\nthe little lamb would go."
    end
  end
end

def scrape(uri)
  return scrape(URI.parse(uri)) unless uri.respond_to?(:open)

  NewSite::MeetReport.new(Wordpress::Meet.new(uri))
end

if $PROGRAM_NAME == __FILE__
  config = {
    cf_account_id: ENV['CF_ACCOUNT_ID'],
    r2_access_key_id: ENV['R2_ACCESS_KEY_ID'],
    r2_access_secret: ENV['R2_ACCESS_SECRET']
  }

  puts scrape(URL).markdown
end
