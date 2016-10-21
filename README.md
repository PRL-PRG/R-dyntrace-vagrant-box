# FreeBSD Vagrant box to experiment with DTrace support in R

## Quickstart

- Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

- Install [Vagrant](https://www.vagrantup.com/)

- Checkout this repository.
  ```sh
  git checkout https://github.com/PRL-PRG/R-dyntrace-vagrant-box.git <path>
  ```

  Due to some archaic [NFS limitations on BSD](http://serverfault.com/questions/660588/file-name-too-long-mount-nfs), the `path` in which you checkout the sources **cannot be longer** than `88-strlen("sandbox")` characters otherwise you will get `File name too long` from `mount_nfs`.

- Build the box
  ```sh
  [host]$ vagrant up
  ```

  This should
  - download the [FreeBSD box](https://atlas.hashicorp.com/freebsd/boxes/FreeBSD-10.3-STABLE)
  - install all tools required to build R
  - install few useful tools such as vim and bash
  - checkout the modified R source code into `/vagrant/R-dyntrace`
  - build it with `./configure --without-recommended-packages --disable-java --enable-dtrace && make`
  - set the `R_HOME=/vagrant/R-dyntrace`
  - add `/vagrant/work/R-dyntrace/lib` to `LD_LIBRARY_PATH`

  Note that the sources are available from the `sandbox` directory so the code editing can be on your local machine. Debugging can be done by remote gdb.

- Check the basics
  ```sh
  [host]$ vagrant up
  ...
  [host]$ vagrant ssh
  [vagrant@ ~]$ cd /vagrant
  [vagrant@ /vagrant]$ sudo ./colmeans-basic.sh
  ```

  - This will run [`colmeans-basic.R`](https://github.com/PRL-PRG/R-dyntrace-vagrant-box/blob/master/sandbox/colmeans-basic.R) which traces the following R script:
    ```r
    len<-100000

    complexvec = complex(r=1:len,i=1:len)
    dim(complexvec) = c(len/2,2)

    compute <- function(x) colMeans(x)

    system.time(compute(complexvec))
    ```
    using three different dtrace scripts:
    - [flowinfo.dtrace](https://github.com/PRL-PRG/R-dyntrace/blob/master/share/dtrace/flowinfo.dtrace) showing the complete flow af an R script (_i.e._ the function calls, the builtins and the promise evaluation and variable lookups).
    - [calltime.dtrace](https://github.com/PRL-PRG/R-dyntrace/blob/master/share/dtrace/calltime.dtrace) showing the count, exclusive and inclusive elapsed time of functions and builtins.
    - [calltime-all.dtrace](https://github.com/PRL-PRG/R-dyntrace/blob/master/share/dtrace/calltime-all.dtrace) showing the the same as the `calltime`, but only within a scope of a given function.

    The first one shows the complete flow of the script :

    - example output of flowinfo:
    ```
    DELTA(us) FLAGS TYPE     -- NAME
        0     0 builtin  -> baseenv
        0     0 builtin  <- baseenv = `<environment>` (4)
        0     0 function -> glue (loc: <unknown>)
        0     0 builtin    -> list
        0     0 builtin    <- list = `list("R-dyntrace", "library", "base", "R", "base")` (19)
        0     0 promise       sep
        0     0 promise       sep = `"/"` (type: 16)
        0     0 promise       collapse
        0     0 promise       collapse = `NULL` (type: 0)
        0     0 function <- glue = `"R-dyntrace/library/base/R/base"` (16) (loc: <unknown>)
        0     0 function -> ..lazyLoad (loc: <unknown>)
        0     0 function   -> glue (loc: <unknown>)
        0     0 builtin      -> list
        0     0 promise           filebase
        0     0 promise           filebase = `"R-dyntrace/library/base/R/base"` (type: 16)
        0     0 builtin      <- list = `list("R-dyntrace/library/base/R/base", "rdx")` (19)
        0     0 promise         sep
        0     0 promise         sep = `"."` (type: 16)
        0     0 promise         collapse
        0     0 promise         collapse = `NULL` (type: 0)
        0     0 function   <- glue = `"R-dyntrace/library/base/R/base.rdx"` (16) (loc: <unknown>)
        0     0 function   -> glue (loc: <unknown>)
        0     0 builtin      -> list
        0     0 lookup            filebase = `"R-dyntrace/library/base/R/base"` (type: 16)
        0     0 builtin      <- list = `list("R-dyntrace/library/base/R/base", "rdb")` (19)
    ```

    - example output of calltime:    
      ```
      Tracing R... Hit Ctrl+c to exit.

      Count
         TYPE       NAME                                COUNT
         builtin    *                                       1
         builtin    /                                       1
         builtin    Im                                      1
         builtin    Re                                      1
         builtin    Sys.getlocale                           1
         builtin    Sys.glob                                1
         builtin    Version                                 1
         builtin    capabilities                            1
         builtin    complex                                 1
         builtin    dim<-                                   1
         builtin    dimnames                                1
         builtin    gc                                      1
         ...

      Exclusive function elapsed times (us)
         TYPE       NAME                                TOTAL
         builtin    capabilities                            0
         builtin    globalenv                               0
         builtin    unlockBinding                           2
         builtin    is.array                                2
         builtin    dimnames                                3
         builtin    sum                                     4
         builtin    is.call                                 4
         builtin    is.expression                           5
         builtin    Sys.getlocale                           6
         builtin    which.max                               6
         builtin    is.character                            7
         function   base::identical                         8
         builtin    lengths                                 9
         builtin    interactive                             9
         function   base::.OptRequireMethods               10
         ...

      Inclusive function elapsed times (us)
         TYPE       NAME                                TOTAL
         builtin    capabilities                            0
         builtin    globalenv                               0
         builtin    unlockBinding                           2
         builtin    is.array                                2
         builtin    dimnames                                3
         builtin    sum                                     4
         builtin    is.call                                 4
         builtin    is.expression                           5
         builtin    Sys.getlocale                           6
         builtin    which.max                               6
         builtin    is.character                            7
         builtin    lengths                                 9
         builtin    interactive                             9
         function   base::identical                        11
         builtin    R.home                                 11
         builtin    /                                      13
         ...
      ```

    - example output of `calltime-compute` (tracking only the `compute function`):

      ```
      Tracing R 'compute' function...

      Count
         TYPE       NAME                                COUNT
         builtin    *                                       1
         builtin    +                                       1
         builtin    Im                                      1
         builtin    Re                                      1
         builtin    dim                                     1
         builtin    dimnames                                1
         builtin    inherits                                1
         builtin    is.array                                1
         function   base::colMeans                          1
         function   base::is.data.frame                     1
         builtin    colMeans                                2
         builtin    lazyLoadDBfetch                         2
         builtin    length                                  3
         builtin    prod                                    3
         total      total                                  20

      Exclusive function elapsed times (us)
         TYPE       NAME                                TOTAL
         builtin    *                                       0
         builtin    dimnames                                0
         builtin    +                                       0
         builtin    is.array                                2
         builtin    dim                                     3
         builtin    inherits                                5
         builtin    length                                  5
         builtin    prod                                   11
         function   base::is.data.frame                    13
         function   base::colMeans                         98
         builtin    lazyLoadDBfetch                       154
         builtin    colMeans                              182
         builtin    Im                                    189
         builtin    Re                                    580
         total      total                                1249

      Inclusive function elapsed times (us)
         TYPE       NAME                                TOTAL
         builtin    *                                       0
         builtin    dimnames                                0
         builtin    +                                       0
         builtin    is.array                                2
         builtin    dim                                     3
         builtin    inherits                                5
         builtin    length                                  5
         builtin    prod                                   11
         function   base::is.data.frame                    18
         builtin    lazyLoadDBfetch                       154
         builtin    colMeans                              182
         builtin    Im                                    189
         builtin    Re                                    580
         function   base::colMeans                       1111
      ```
