#! /usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'open-uri'
require 'yaml'

require 'nokogiri'

URL = ARGV[0] || 'https://45degreesmc.com/calendar/'

def load_page(uri)
  return load_page(URI.parse(uri)) unless uri.respond_to?(:open)

  content = uri.open.read
  yield content if block_given?
  content
end

def get_meets(table)
  table.css('tbody > tr')
       .map { |tr| tr.css('td').map { |el| el.text.strip } }
       .reject { |values| values.uniq.count == 1 && values.uniq.first.empty? }
end

def generate_csv(years, meets)
  CSV.generate do |csv|
    csv << %i[year month dates hut area]
    years.zip(meets).each do |(this_year, meets_this_year)|
      meets_this_year.each { |meet| csv << [this_year] + meet }
    end
  end
end

def generate_hash(years, meets, fields = %w[month dates hut area])
  years.zip(meets).map do |year, this_year|
    {
      'year' => year.to_i,
      'meets' => this_year.map { |this_month| Hash[fields.zip(this_month)] }
    }
  end
end

years = Nokogiri::HTML(load_page(URL)).css('h2 strong').map { |el| el.text.split.first }
meets = Nokogiri::HTML(load_page(URL)).css('table').map(&method(:get_meets))

puts generate_hash(years, meets).to_yaml
