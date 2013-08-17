# msgpack.org

This is a code repository for [msgpack.org](http://msgpack.org/) website.

## Publishing the API document at the top page of msgpack.org

The API document of msgpack-related project at the top page of msgpack.org are generated automatically
by crawling github repository.

### How to add the API document

1. Please add the sentence ```msgpack.org[ProjctName]``` into ```Description``` of yoru github repository.
2. Please add the document named as follows at root of github repository.
  * msgpack.org.md
  * README.md
  * README.markdown
  * README.rdoc
  * README.rst
  * README

The priority to show at msgpack.org is ```msgpack.org.md``` >```README.md``` > ```README.markdown``` > ```README.rdoc``` > ```README.rst``` > ```README```. You can choose to show ```msgpack.org.md``` at msgpack.org separately from README.md at your github page.
3. Please wait a moment. [A crawler](https://github.com/msgpack/website/blob/master/update-index.rb) visits your github repository each hour, and it's update msgpack.org page automatically.

### Tutorial

This section describes how to update msgpack.org page with an example of msgpack-java.

1. Add ```msgpack.org[Java]``` into ```Description``` of msgpack-java.
2. Add ```msgpack.org.md``` into msgpack-java.
3. Please wait a moment. [A crawler]() visits your github repository each hour, and it's update msgpack.org page automatically.
