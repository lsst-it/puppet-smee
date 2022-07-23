# smee

## Table of Contents

1. [Overview](#overview)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)

## Overview

Manages the smee.io webhook proxy service client

## Usage

```puppet
class { smee:
  url  => 'https://foo.example.org',
  path => '/payload',
  port => 1234,
}
```

## Reference

See [REFERENCE](REFERENCE.md)

## See Also

* https://smee.io/
* https://www.npmjs.com/package/smee-client
