download-make-install Cookbook
===============================

This cookbook run download target source, extract, configure, make, make install process.

Requirements
------------

#### cookbook
- `build-essential` - building some target source needs gcc/g++ and related headers.

Attributes
----------

#### download-make-install::default

`node['download_make_install']['install_prefix']` - install path prefix: default is '/usr/local'
`node['download_make_install']['packages']` - build target source definitions hash-array. hash include few keys. `url` is target source file location, required. `configure_options` value will pass-through to ./configure option, optional. `target` is expected installed file/directory after installation, optional. if `target` is omitted then try to download/install everytime.

Usage
-----
#### download-make-install::default

Include `download_make_install` in your node's `run_list` and set packages information:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[download-make-install]"
  ],
  "override_attributes" : {
    "download_make_install": {
      "install_prefix" : "/usr/local/",
      "packages": [
        {
          "url": "http://mecab.googlecode.com/files/mecab-0.994.tar.gz",
          "configure_options": "--with-charset=utf8 --enable-utf8-only",
          "target": "/usr/local/lib/libmecab.so"
        },
        {
          "url": "http://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz",
          "configure_options": "--with-charset=utf8",
          "target": "/usr/local/lib/mecab"
        },
        {
          "url": "http://www.sqlite.org/2013/sqlite-autoconf-3080200.tar.gz",
          "target": "/usr/local/bin/sqlite3"
        }
      ]
    }
  }
}
```

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Takayuki Shimizukawa
License: Apache 2.0
