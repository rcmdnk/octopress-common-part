module Jekyll
  class Site
    attr_accessor :common_parts
  end

  class CommonParts < Site
    class << self
      def reset(site)
        site.common_parts = []
      end

      def post_read(site)
        base = Jekyll.sanitized_path(site.source, "_common_parts")
        return unless File.exist?(base)
        entries = Dir.chdir(base) do
          EntryFilter.new(site, base).filter(Dir['**/*'])
        end
        entries.delete_if { |e| File.directory?(Jekyll.sanitized_path(base, e)) }

        site.common_parts = entries.map do |entry|
          Page.new(site, site.source, '_common_parts', entry)
        end.reject do |entry|
          entry.nil?
        end
      end

      def site_payload(site)
        {
          "jekyll" => {
            "version" => Jekyll::VERSION,
            "environment" => Jekyll.env
          },
          "site"   => Utils.deep_merge_hashes(site.config,
            Utils.deep_merge_hashes(Hash[site.collections.map{|label, coll| [label, coll.docs]}], {
              "time"         => site.time,
              "posts"        => site.posts.sort { |a, b| b <=> a },
              "pages"        => site.pages,
              "static_files" => site.static_files.sort { |a, b| a.relative_path <=> b.relative_path },
              "html_pages"   => site.pages.select { |page| page.html? || page.url.end_with?("/") },
              "categories"   => site.post_attr_hash('categories'),
              "tags"         => site.post_attr_hash('tags'),
              "collections"  => site.collections,
              "documents"    => site.documents,
              "data"         => site.site_data
          }))
        }
      end

      def pre_render(site)
        payload = site_payload(site)
        site.config.merge!('common_parts' => {})
        site.common_parts.each do |c|
          c.render(site.layouts, payload)
          site.config['common_parts'][c.name] = c.output
        end
      end
    end

    if defined?(Jekyll::Hooks)
      Jekyll::Hooks.register :site, :after_reset do |site|
        CommonParts::reset(site)
      end
      Jekyll::Hooks.register :site, :post_read do |site|
        CommonParts::post_read(site)
      end
      Jekyll::Hooks.register :site, :pre_render do |site, payload|
        CommonParts::pre_render(site)
        payload = CommonParts::site_payload(site)
      end
    else
      require 'octopress-hooks'

      class SiteHook < Octopress::Hooks::Site
        def reset(site)
          CommonParts::reset(site)
        end

        def post_read(site)
          CommonParts::post_read(site)
        end

        def pre_render(site)
          CommonParts::pre_render(site)
        end
      end
    end
  end

  class CommonPartsTag < Liquid::Tag
    def initialize(name, markup, tokens)
      super
      @part = markup.strip
    end

    def render(context)
      context['site.common_parts'][@part]
    end
  end
end

Liquid::Template.register_tag('common_part', Jekyll::CommonPartsTag)
