---
layout: post
title:  "First Post!"
author: samuel
categories: [ blogging, jekyll, markdown ]
image: https://images.unsplash.com/photo-1543545342-eeb71c9a7407?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=cf15f8e35cfcf5ceb4adc69aecca59ff&auto=format&fit=crop&w=2550&q=80
featured: false
hidden: false
---

First Post!

### Blogging again...

I'm trying out Jekyll for the first time to create my blog. I've used WordPress and Blogger before this to record random how-tos, but never got into the habit of regularly posting.

Every now and then I get this idea that I should be a bit more organized and document my projects. Every time I start a new project application, I start a text document that lists in bullet points what features I want to build. Sometimes it includes requirements that the application needs to fulfill. Sometimes I have data schemas listed in the same text file. By the time I've built up the application scaffolding and started filling up the logic, the text file is abandoned, or adapted into a readme file.

The project grows into a monstrosity (every time!). I start referencing other techniques and code in my previous projects, improving upon the old iteration and adapting it for use in the current project.

This blog is an attempt at documenting my usual application development process, for reference in my future projects. 

### What's Jekyll

Regular blog software reads some kind of formatted plaintext (often Markdown) from a database and renders the blog page according to your design template. The rendering is usually done per browser request, so it requires that you have a server to host the blog software. That also means you need to maintain the server, the language runtime of the blog software and the blog software itself, as well as the database.

Jekyll is a static site generator. It reads the collected formatted plaintext files on your filesystem and renders everything at once into a collection of interlinked webpages. If you have a new post, you render everything again. Since there is no rendering on the fly, you can make use of simple web servers and do away with server maintenance. 

This also allows you to take advantage of free and/or dirt cheap web hosting services, like [GitHub Pages](https://pages.github.com/) or [Amazon S3](https://aws.amazon.com/s3/). At present, I'm using [Github Pages](https://pages.github.com/), because I have a [GitHub account](https://github.com/samloh84) and it costs literally nothing to host on GitHub.

Jekyll also has alot of themes available. I chose [Mediumish](https://jekyllthemes.io/theme/mediumish) from the [Jekyll Themes](https://jekyllthemes.io) website.

For this website, I'm using the following procedure to install Jekyll and write this page... (how meta!)

1. I'm following the Mac instructions to install the Jekyll binary from the [Jekyll Installation Instructions](https://jekyllrb.com/docs/installation/macos/):
    
    ```bash
    sudo gem install bundler jekyll
    ```
        
2. Download the theme and install the additional plugins required for the theme
        
    ```bash   
    curl -SLj -o mediumish-theme-jekyll-master.zip https://github.com/wowthemesnet/mediumish-theme-jekyll/archive/master.zip
    unzip mediumish-theme-jekyll-master.zip
    cd mediumish-theme-jekyll-master   
    sudo bundle install
    ``` 
        
3. Start hacking the various HTML templates and Markdown files. You can run the following command to have Jekyll re-render all your pages on every change and allow you to refresh the browser to see your changes.
    ```bash
    bundle exec jekyll serve
    ```

4. Reading further, there's a feature for GitHub pages to auto-build your Jekyll site. I'm following this [guide](http://jmcglone.com/guides/github-pages/). After enabling the GitHub pages feature in my project settings, modifying my blog templates and writing this post, I'm pushing the changes to GitHub.
    ```bash
    git commit -m "Initial Commit"
    git push
    ``` 

### Other resources

Formatting in Markdown is a little tricky, so it's always good to have a reference.
* [Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
* [Kramdown Markdown Reference](https://kramdown.gettalong.org/quickref.html)

Mediumish needs a splash photograph for each post, so it's good to have a free resource of stock images.
* [Free Photos from Unsplash](https://unsplash.com/)
    