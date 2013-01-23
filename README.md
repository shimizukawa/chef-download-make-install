download-make-install Cookbook
===============================

This cookbook run download target source, extract, configure, make, make install process.

Requirements
------------

#### packages
- `build-essential` - building some target source needs gcc/g++ and related headers.

Attributes
----------

#### chefenv::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['python_build']['install_prefix']</tt></td>
    <td>string</td>
    <td>install path prefix</td>
    <td><tt>'/usr/local'</tt></td>
  </tr>
</table>

Usage
-----
#### chefenv::default

Just include `chefenv` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[build-python]"
  ],
  "override_attributes" : {
    "download_make_install": {
      "install_prefix" : '/usr/local/',
      "packages": [
        {:url => 'http://mecab.googlecode.com/files/mecab-0.994.tar.gz'},
        {:url => 'http://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz'}
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
