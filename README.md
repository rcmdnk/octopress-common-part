# octopress-common-part

Make Octopress faster by pre-rendering common parts and inserting.

## How it works

In your Octopress site,
there may be a lot of common parts in each page or post,
such a header or sidebar, in which no page or post values are used.

Normally, jekyll renders these common parts for each page or post,
but the results are exactly same, extremely wasteful.

octopress-common-part separates these common parts,
renders before rendering pages and posts,
then inserts these common parts to pages and posts by the tag
when they are rendered.

## Requirement

If you are using Octopress, or Jekyll version >= 3.0, nothing is needed.

Otherwise,
need gem:

    $ gem install octopress-hooks

## Installation

* Copy **plugins/_common_parts.rb** to **plugins/**.

In addition, remove `render` and `write` methods
from **plugins/category_generator.rb***.

```diff
--- a/plugins/category_generator.rb
+++ b/plugins/category_generator.rb
@@ -90,15 +90,11 @@ module Jekyll
     #  +category+     is the category currently being processed.
     def write_category_index(category_dir, category)
       index = CategoryIndex.new(self, self.source, category_dir, category)
-      index.render(self.layouts, site_payload)
-      index.write(self.dest)
       # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
       self.pages << index

       # Create an Atom-feed for each index.
       feed = CategoryFeed.new(self, self.source, category_dir, category)
-      feed.render(self.layouts, site_payload)
-      feed.write(self.dest)
       # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
       self.pages << feed
     end
```

They are unnecessary in any case, because
they are rendered and written when normal pages are rendered and written, too.

## Usage

Make a directory **source/_common_parts**.

Put your common parts in there.
You can see examples in **octopress-common-parts/source/_common_parts/**.

Such common_header.html is like:

```html
---
layout: null
---
{% capture root_url %}{{ site.root | strip_slash }}{% endcapture %}
<header role="banner">{% include header.html %}</header>
<nav role="navigation">{% include navigation.html %}</nav>
```

It is a part of **source/_layouts/default.html**.

Then, replace the part in such **default.html** by common_part tag:

```diff
--- a/source/_layouts/default.html
+++ b/source/_layouts/default.html
@@ -1,8 +1,7 @@
 {% capture root_url %}{{ site.root | strip_slash }}{% endcapture %}
 {% include head.html %}
 <body {% if page.body_id %} id="{{ page.body_id }}" {% endif %} {% if page.sidebar == false %} class="no-sidebar" {% endif %} {% if page.sidebar == 'collapse' or site.sidebar == 'collapse' %} class="collapse-sidebar sidebar-footer" {% endif %}>
-  <header role="banner">{% include header.html %}</header>
-  <nav role="navigation">{% include navigation.html %}</nav>
+{% common_part common_header.html %}
   <div id="main">
     <div id="content">
       {{ content | expand_urls: root_url }}
```
