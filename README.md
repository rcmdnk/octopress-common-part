# octopress-common-part

Make Octopress faster by pre-rendering common parts and inserting.

## How it works

In your Octopress site,
there may be a lot of common parts in each page or post,
such a header or sidebar, in which no page or post values are used.

Normally, jekyll renders these common parts for each page or post,
but the results are exactly same. It is extremely wasteful.

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

## Usage

Make a directory **source/_common_parts**.

Or set your own common directory in **_config.yml**:

    # common parts
    common_parts_dir: _my_common_parts

and make **source/my ommon parts dirctory>**. It must starts with `_`.

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
