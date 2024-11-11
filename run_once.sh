# "#################################################"
# Dockerfile to build a GitHub Pages Jekyll site
#   - Ubuntu 22.04
#   - Ruby 3.1.2
#   - Jekyll 3.9.3
#   - GitHub Pages 288
#
#   This code is from the following Gist:
#   https://gist.github.com/BillRaymond/db761d6b53dc4a237b095819d33c7332#file-post-run-txt
#
# Instructions:
#  1. Copy all the text in this file
#  2. Create a file named Dockerfile and paste the code
#  3. Create the Docker image/container
#  4. Locate the shell file in this Gist file and run it in the local repo's root
# "#################################################"
FROM ubuntu:22.04

# "#################################################"
# "Get the latest APT packages"
# "apt-get update"
RUN apt-get update

# "#################################################"
# "Install Ubuntu prerequisites for Ruby and GitHub Pages (Jekyll)"
# "Partially based on https://gist.github.com/jhonnymoreira/777555ea809fd2f7c2ddf71540090526"
RUN apt-get -y install git \
    curl \
    autoconf \
    bison \
    build-essential \
    libssl-dev \
    libyaml-dev \
    libreadline6-dev \
    zlib1g-dev \
    libncurses5-dev \
    libffi-dev \
    libgdbm6 \
    libgdbm-dev \
    libdb-dev \
    apt-utils
    
# "#################################################"
# "GitHub Pages/Jekyll is based on Ruby. Set the version and path"
# "As of this writing, use Ruby 3.1.2
# "Based on: https://talk.jekyllrb.com/t/liquid-4-0-3-tainted/7946/12"
ENV RBENV_ROOT /usr/local/src/rbenv
ENV RUBY_VERSION 3.1.2
ENV PATH ${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:$PATH

# "#################################################"
# "Install rbenv to manage Ruby versions"
RUN git clone https://github.com/rbenv/rbenv.git ${RBENV_ROOT} \
  && git clone https://github.com/rbenv/ruby-build.git \
    ${RBENV_ROOT}/plugins/ruby-build \
  && ${RBENV_ROOT}/plugins/ruby-build/install.sh \
  && echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

# "#################################################"
# "Install ruby and set the global version"
RUN rbenv install ${RUBY_VERSION} \
  && rbenv global ${RUBY_VERSION}

# "#################################################"
# "Install the version of Jekyll that GitHub Pages supports"
# "Based on: https://pages.github.com/versions/"
# "Note: If you always want the latest 3.9.x version,"
# "       use this line instead:"
# "       RUN gem install jekyll -v '~>3.9'"
RUN gem install jekyll -v '3.9.3'
run-once-after-dockerfile.sh
#!/bin/sh
# "#################################################"
# "This file is based on a Gist, located here:"
#    "https://gist.github.com/BillRaymond/db761d6b53dc4a237b095819d33c7332#file-post-run-txt"
# "Steps to finalize a Docker image to use GitHub Pages and Jekyll"
# "Instructions:"
# " 1. Open a terminal window and cd into your repo"
# " 3. Run the script, like this:
# "      sh script-name.sh"
# "#################################################"

# Display current Ruby version
echo "Ruby version"
ruby -v

# Display current Jekyll version
echo "Jekyll version"
jekyll -v

# Add a blank Jekyll site
# echo "Create a new Jekyll site"
# NOTE: Want a blank site? Uncomment the following line
#       and also comment out the next "Add Jekyll site" lines
# echo "Create a new Jekyll blank site"
# jekyll new . --skip-bundle --force --blank

# Add Jekyll site
echo "Create a new Jekyll site with the default theme"
jekyll new . --skip-bundle --force

# Jekyll creates a .gitignore file, but it can be improved, so delete it
# NOTE: Comment out the following lines if you want to keep the original .gitignore file 
echo "Deleting default .gitignore file Jekyll generated"
GITIGNORE=.gitignore
if test -f "$GITIGNORE"; then
    rm $GITIGNORE
fi

# Create a new .gitignore file and populate it
# NOTE: Comment out the following lines if you want to keep the original .gitignore file
echo "Create a new .gitignore file"
touch $GITIGNORE

# Populate the new .gitignore file
# NOTE: Comment out the following lines if you want to keep the original .gitignore file
echo "Populating the .gitignore file"
echo "_site/" >> $GITIGNORE
echo ".sass-cache/" >> $GITIGNORE
echo ".jekyll-cache/" >> $GITIGNORE
echo ".jekyll-metadata" >> $GITIGNORE
echo ".bundle/" >> $GITIGNORE
echo "vendor/" >> $GITIGNORE
echo "**/.DS_Store" >> $GITIGNORE

# Configure Jekyll for GitHub Pages
echo "Add GitHub Pages to the bundle"
bundle add "github-pages" --group "jekyll_plugins" --version 228

# webrick is a technology that has been removed by Ruby, but needed for Jekyll
echo "Add required webrick dependency to the bundle"
bundle add webrick

# Install and update the bundle
echo "bundle install"
bundle install
echo "bundle update"
bundle update

# Modify the _config.yml file
# baseurl: "/github-pages-with-docker" # the subpath of your site, e.g. /blog
# url: "https://YourGitHubUserName.github.io" # the base hostname & protocol for your site, e.g. http://example.com

# Initialize Git and add a commit message
git init -b main
git add -A
git commit -m "initial commit"

# Get the presumed value for the baseurl (this folder name)
var=$(pwd)
BASEURL="$(basename $PWD)"

# Done! Provide informative text for next steps
echo ""
echo "\033[1;32mDone configuring your Jekyll site! Here are the next steps:\033[00m"
echo "1. Modify the baseurl and url in your _config.yml file:"
echo "    The baseurl is \033[1m/$BASEURL\033[0m"
echo "    The url is \033[1mhttps://YourGitHubUsername.github.io\033[0m"
echo "2. Run Jekyll for the first time on your computer:"
echo "    \033[1mbundle exec jekyll serve --livereload\033[0m"
echo "    Look for the site at port 4000 (ex http://127.0.0.1:4000/)"
echo "    After testing, type CONTROL+C to stop Jekyll"
echo "3. Commit all your changes to Git locally"
echo "4. Publish your site to a new GitHub repo"
echo "    In Visual Studio Code, type:"
echo "    COMMAND+SHIFT+P (Mac) or CONTROL+SHIFT+P (Windows)"
echo "    Search for and select \033[1mPublish to GitHub\033[0m"
echo "    In most cases, you will make the repo public"
echo "    Follow the steps to complete the process"
echo "5. In GitHub, enable GitHub Pages in the repo settings and test"
echo "    https://YourGitHubUserName.github.io/$BASEURL"
echo "6. Continue developing locally and pushing changes to GitHub"
echo "    All your changes will publish to the website automatically after a few minutes"
echo ""
echo "7. Optionally, create a README.md at the root of this folder to provide yourself"
echo "    and others with pertinent details for building and using the repo"