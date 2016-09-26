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

- In one terminal
  ```sh
  [host]$ vagrant ssh
  [vagrant@ /vagrant/R-dyntrace]$ sudo share/dtrace/flowinfo.dtrace
  ```

- In second terminal
  ```sh
  [host]$ vagrant ssh
  [vagrant@ /vagrant/R-dyntrace]$ src/main/R.bin
  > basename("/")
  ```

  this should show the following in the first terminal:
  ```
  DELTA(us) FLAGS TYPE     -- NAME
          0     1 function -> base::basename (loc: <unknown>)
         13     0 promise       path
       1210     0 promise       path = `"/"` (type: 16)
         16     0 builtin    -> basename
         20     0 builtin    <- basename = `""` (16)
         14     1 function <- base::basename = `""` (16) (loc: <unknown>)
  ```
