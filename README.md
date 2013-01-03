# msgpack.org

This is a code repository for [msgpack.org](http://msgpack.org/) website.

Modicifications on this repository are published to the website automatically.


# Publishing website at &lt;lang&gt;.msgpack.org (for committers)

MessagePack repository administrators can publish website on http://&lt;lang&gt;.msgpack.org domain.

(If you didn't yet, please read this article as well: [Updates on the MessagePack Project](https://gist.github.com/2892856))

## 1. Creating clean "gh-pages" branch

    # Use your project name here
    NAME=ruby
    
    # Clone the repository to ./msgpack-<lang>-website directory
    git clone git@github.com:msgpack/msgpack-$NAME.git msgpack-$NAME-website
    cd msgpack-$NAME-website
    
    # Create gh-pages branch
    git checkout --orphan gh-pages

    # Remove all files from the old working tree
    rm -rf .

## 2. Adding "CNAME" file to the branch

    # Create "CNAME" file which has "<lang>.msgpack.org" line
    echo $NAME.msgpack.org > CNAME
    git add CNAME
    
    # Push the branch to github
    git commit -a -m "GitHub Pages for $NAME.msgpack.org"
    git push -u origin gh-pages

## 3. Confirm the website

Wait several minutes until github finishes to generate the website. Then access to `http://<lang>.msgpack.org/`.

You can use `git clone -b gh-pages` to clone the branch from other computers as following:

    git clone git@github.com:msgpack/msgpack-$NAME.git msgpack-$NAME-website -b gh-pages

See http://ruby.msgpack.org and https://github.com/msgpack/msgpack-ruby/tree/gh-pages for an example.

