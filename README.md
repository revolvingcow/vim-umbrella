Umbrella
========

Runs unit tests and code coverage within the project.

Introduction
------------

There seems to be a plethora of ways to run unit tests and provide
code coverage. It is fine to have a pretty print out showing what
areas need more eyes on them but we can do better. By providing
quicker feedback the aim is to minimize errors before committing
as well as maximizing our testable code base.

Installation
------------

Using [pathogen.vim](https://github.com/tpope/vim-pathogen)

```sh
    cd ~/.vim/bundle
    git clone git://github.com/revolvingcow/vim-umbrella.git
```

Restart `vim` and then:

```vim
    :Helptags
```

Once help tags have been generated, you can view the manual with

```vim
    :help umbrella
```

-

Using [vundle](https://github.com/gmarik/vundle)

Append the plugin to the list of existing bundles:

```sh
    Bundle "revolvingcow/vim-umbrella"
```

Then quit (`:q`) and go back in to `vim` and run `:BundleInstall`


How it works
------------

```vim
    :Umbrella
```

```vim
    :UmbrellaRefresh
```

```vim
    :UmbrellaClear
```

```vim
    nnoremap    <F7>   :<C-U>Umbrella<CR>
    ...
```

License
-------

Umbrella is licensed under the same terms as Vim itself (see [`:help
license`](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license)).

Thanks
------

Many thanks go to [syntastic](https://github.com/scrooloose/sytastic) and
[makeshift](https://github.com/johnsyweb/vim-makeshift). Both of these
provided a great template to extend on.
