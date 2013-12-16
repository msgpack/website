# msgpack.org

This repository manages [msgpack.org website](http://msgpack.org/).

## Publishing your msgpack implementation to msgpack.org

The list of msgpack implementations on the [msgpack.org website](http://msgpack.org/) is generated automatically.

[A crawler](https://github.com/msgpack/website/blob/master/update-index.rb) searches Github repositories
to find specific repositories and put summary documents to the website.

## How to list up your implementation on msgpack.org

1. Add the keyword ```msgpack.org[ProjctName]``` to description of your github repository
    * ```ProjectName``` is typically programming language name such as ```ruby```
2. Add one of following files to the root directory of your github repository:
    1. msgpack.org.md
    2. README.md
    3. README.markdown
    4. README.rdoc
    5. README.rst
    6. README
3. Wait a moment. [The crawler](https://github.com/msgpack/website/blob/master/update-index.rb) visits your github repository every hour.
4. Your implementation will be listed to the website

The crawler copies content of a file to msgpack.org website. Former file name has priority (```msgpack.org.md``` > ```README.md``` > ...).

## Examples

* https://github.com/msgpack/msgpack-java
* https://github.com/msgpack/msgpack-ruby

