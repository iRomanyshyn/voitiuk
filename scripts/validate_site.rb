#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "pathname"
require "set"
require "uri"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path
BUILD = ROOT.join("_site")
ERRORS = []
WARNINGS = []

def error(message)
  ERRORS << message
end

def warning(message)
  WARNINGS << message
end

def load_yaml(path)
  YAML.safe_load(path.read(encoding: "UTF-8"), permitted_classes: [Date, Time], aliases: true)
rescue Psych::Exception => e
  error("Invalid YAML in #{path.relative_path_from(ROOT)}: #{e.message}")
  nil
end

def front_matter(path)
  text = path.read(encoding: "UTF-8")
  return nil unless text.start_with?("---\n", "---\r\n")

  match = text.match(/\A---\s*\r?\n(.*?)\r?\n---\s*(?:\r?\n|\z)/m)
  return nil unless match

  data = YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true) || {}
  { data: data, body: text[match.end(0)..] || "" }
rescue Psych::Exception => e
  error("Invalid front matter in #{path.relative_path_from(ROOT)}: #{e.message}")
  nil
end

def normalize_url(value)
  return nil if value.nil?

  raw = value.to_s.strip
  return nil if raw.empty?

  path = URI.parse(raw).path
  path = "/#{path}" unless path.start_with?("/")
  path.gsub(%r{/+}, "/")
rescue URI::InvalidURIError
  raw
end

def source_url(path, data)
  explicit = normalize_url(data["permalink"])
  return explicit if explicit

  relative = path.relative_path_from(ROOT).to_s.tr("\\", "/")
  relative = relative.sub(/\.(?:md|markdown|html)\z/i, "")
  relative = relative.sub(%r{/(?:index)\z}, "/")
  relative = "/" if relative == "index"
  relative = "/#{relative}" unless relative.start_with?("/")
  File.extname(relative).empty? && !relative.end_with?("/") ? "#{relative}/" : relative
end

def local_asset?(value)
  value.is_a?(String) && value.start_with?("/") && !value.start_with?("//")
end

def asset_path(value)
  clean = URI.parse(value).path.sub(%r{\A/}, "")
  ROOT.join(CGI.unescape(clean))
rescue URI::InvalidURIError
  ROOT.join(value.sub(%r{\A/}, ""))
end

def validate_asset(value, context)
  return unless local_asset?(value)
  error("Missing asset #{value.inspect} (#{context})") unless asset_path(value).file?
end

def walk_source_references(value, valid_ids, context = "data")
  case value
  when Hash
    value.each do |key, child|
      if key.to_s == "source_id" && child
        error("Unknown source_id #{child.inspect} in #{context}") unless valid_ids.include?(child.to_s)
      elsif key.to_s == "source_ids" && child
        Array(child).each do |id|
          error("Unknown source_id #{id.inspect} in #{context}") unless valid_ids.include?(id.to_s)
        end
      end
      walk_source_references(child, valid_ids, "#{context}.#{key}")
    end
  when Array
    value.each_with_index { |child, index| walk_source_references(child, valid_ids, "#{context}[#{index}]") }
  end
end

def built_url(path)
  relative = path.relative_path_from(BUILD).to_s.tr("\\", "/")
  return "/" if relative == "index.html"
  return "/#{relative.sub(%r{/index\.html\z}, "/")}" if relative.end_with?("/index.html")

  "/#{relative}"
end

def resolve_built_file(url_path)
  path = CGI.unescape(url_path.to_s)
  path = "/" if path.empty?
  relative = path.sub(%r{\A/}, "")
  candidates = []
  if path.end_with?("/")
    candidates << BUILD.join(relative, "index.html")
  else
    candidates << BUILD.join(relative)
    candidates << BUILD.join(relative, "index.html")
    candidates << BUILD.join("#{relative}.html") if File.extname(relative).empty?
  end
  candidates.find(&:file?)
end

def internal_reference(value, current_url)
  return nil if value.nil? || value.empty?
  return nil if value.start_with?("mailto:", "tel:", "javascript:", "data:", "blob:", "//")

  uri = URI.parse(value)
  return nil if uri.scheme || uri.host

  resolved = URI.join("https://voitiuk.invalid#{current_url}", value)
  [resolved.path.empty? ? current_url : resolved.path, resolved.fragment]
rescue URI::InvalidURIError
  nil
end

def html_anchors(path, cache)
  cache[path] ||= begin
    html = path.read(encoding: "UTF-8")
    html.scan(/\s(?:id|name)\s*=\s*["']([^"']+)["']/i).flatten.map { |id| CGI.unescapeHTML(id) }.to_set
  end
end

unless BUILD.directory?
  warn "ERROR: _site does not exist. Run `bundle exec jekyll build` first."
  exit 1
end

data_files = ROOT.join("_data").glob("*.yml")
data = data_files.to_h { |path| [path.basename(".yml").to_s, load_yaml(path)] }
sources = data.fetch("sources", {}) || {}
valid_source_ids = sources.keys.map(&:to_s).to_set
data.each { |name, value| walk_source_references(value, valid_source_ids, "_data/#{name}.yml") }

source_files = ROOT.glob("{*.md,*.html,*.xml,*.txt,.well-known/**/*.{md,html,xml,txt},en/**/*.{md,html,xml,txt},uk/**/*.{md,html,xml,txt}}")
pages = source_files.filter_map do |path|
  parsed = front_matter(path)
  next unless parsed

  page = parsed[:data]
  page["__path"] = path
  page["__url"] = source_url(path, page)
  walk_source_references(page, valid_source_ids, path.relative_path_from(ROOT).to_s)
  validate_asset(page["image"], path.relative_path_from(ROOT).to_s) if page["image"]
  page
end

pages.group_by { |page| page["__url"] }.each do |url, matches|
  next if url.nil? || matches.length == 1
  files = matches.map { |page| page["__path"].relative_path_from(ROOT) }.join(", ")
  error("Duplicate permalink #{url}: #{files}")
end

pages_by_url = pages.to_h { |page| [page["__url"], page] }
pages.select do |page|
  %w[en uk].include?(page["lang"]) &&
    page["layout"] != "redirect" &&
    page["page_key"] != "not-found"
end.each do |page|
  locale = page["lang"]
  own_key = "alternate_#{locale}"
  own_alternate = normalize_url(page[own_key])
  other_locale = locale == "en" ? "uk" : "en"
  other_key = "alternate_#{other_locale}"
  other_alternate = normalize_url(page[other_key])
  context = page["__path"].relative_path_from(ROOT)

  error("#{context} is missing #{own_key}") unless own_alternate
  error("#{context} has #{own_key}=#{own_alternate.inspect}, expected #{page['__url'].inspect}") if own_alternate && own_alternate != page["__url"]
  error("#{context} is missing #{other_key}") unless other_alternate
  next unless other_alternate

  pair = pages_by_url[other_alternate]
  if pair.nil?
    error("#{context} points to missing language pair #{other_alternate}")
  else
    error("#{context} pairs with #{other_alternate}, but its lang is #{pair['lang'].inspect}") unless pair["lang"] == other_locale
    reciprocal = normalize_url(pair[own_key])
    error("#{context} and #{pair['__path'].relative_path_from(ROOT)} have mismatched alternates") unless reciprocal == page["__url"]
  end
end

works = data.fetch("works", []) || []
works.each do |work|
  id = work["id"] || "unknown"
  validate_asset(work["image"], "work #{id} image")
  validate_asset(work["thumbnail"], "work #{id} thumbnail")
  %w[en uk].each do |locale|
    expected = "/#{locale}/works/#{work['slug']}/"
    detail = pages.find { |page| page["work_id"] == id && page["lang"] == locale }
    error("Work #{id} has no #{locale.upcase} detail page") unless detail
    error("Work #{id} #{locale.upcase} detail page should use #{expected}, got #{detail['__url']}") if detail && detail["__url"] != expected
    error("Work #{id} URL was not generated: #{expected}") unless resolve_built_file(expected)
  end
end

articles = data.fetch("articles", []) || []
articles.each_with_index do |article, index|
  validate_asset(article["image"], "_data/articles.yml item #{index + 1}")
  %w[en uk].each do |locale|
    url = normalize_url(article.dig("url", locale))
    error("Article item #{index + 1} is missing url.#{locale}") unless url
    error("Article URL was not generated: #{url}") if url && !resolve_built_file(url)
  end
end

red_book = data["red_book_2026"]
if red_book
  base = red_book.dig("meta", "assets_base")
  extension = red_book.dig("meta", "image_extension") || ".jpg"
  Array(red_book["series"]).each do |series|
    Array(series["works"]).each do |work|
      slug = work["slug"]
      validate_asset("#{base}/full/#{slug}#{extension}", "Red Book full image #{slug}")
      validate_asset("#{base}/thumbs/#{slug}#{extension}", "Red Book thumbnail #{slug}")
    end
  end
end

today = ENV["VALIDATION_DATE"] ? Date.parse(ENV.fetch("VALIDATION_DATE")) : Date.today
def validate_current_exhibitions(value, today, context = "_data/exhibitions.yml")
  case value
  when Hash
    if value["current"] == true && value["end_date"]
      end_date = Date.parse(value["end_date"].to_s)
      error("#{context} is marked current but ended on #{end_date}") if end_date < today
    end
    value.each { |key, child| validate_current_exhibitions(child, today, "#{context}.#{key}") }
  when Array
    value.each_with_index { |child, index| validate_current_exhibitions(child, today, "#{context}[#{index}]") }
  end
rescue Date::Error
  error("Invalid end_date in #{context}: #{value['end_date'].inspect}")
end
validate_current_exhibitions(data["exhibitions"], today) if data["exhibitions"]

anchor_cache = {}
BUILD.glob("**/*.html").each do |html_path|
  current_url = built_url(html_path)
  html = html_path.read(encoding: "UTF-8")
  html.scan(/<img\b.*?>/mi).each do |tag|
    next if tag.match?(/\bdata-lightbox-image\b/i)

    %w[alt width height decoding].each do |attribute|
      error("Image missing #{attribute}= on #{current_url}: #{tag.gsub(/\s+/, ' ')[0, 160]}") unless tag.match?(/\b#{attribute}\s*=/i)
    end
    next if tag.match?(/\bloading\s*=/i) || tag.match?(/\bfetchpriority\s*=\s*["']high["']/i)

    error("Image missing loading= on #{current_url}: #{tag.gsub(/\s+/, ' ')[0, 160]}")
  end
  references = html.scan(/\s(?:href|src|action|poster)\s*=\s*["']([^"']+)["']/i).flatten
  html.scan(/\ssrcset\s*=\s*["']([^"']+)["']/i).flatten.each do |srcset|
    references.concat(srcset.split(",").map { |candidate| candidate.strip.split(/\s+/, 2).first })
  end

  references.uniq.each do |reference|
    resolved = internal_reference(reference, current_url)
    next unless resolved

    target_url, fragment = resolved
    target = resolve_built_file(target_url)
    if target.nil?
      error("Broken internal reference #{reference.inspect} on #{current_url}")
      next
    end
    next unless fragment && target.extname == ".html"

    decoded_fragment = CGI.unescape(fragment)
    error("Missing anchor ##{decoded_fragment} in #{target_url} (linked from #{current_url})") unless html_anchors(target, anchor_cache).include?(decoded_fragment)
  end
end

WARNINGS.uniq.sort.each { |message| warn "WARNING: #{message}" }
ERRORS.uniq.sort.each { |message| warn "ERROR: #{message}" }

if ERRORS.empty?
  puts "Site validation passed (#{pages.length} source pages, #{works.length} works, #{articles.length} publication records)."
  exit 0
end

warn "Site validation failed with #{ERRORS.uniq.length} error(s) and #{WARNINGS.uniq.length} warning(s)."
exit 1
