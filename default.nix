#
# This file is just a script to setup the environment using Nix and is not typically used
# in practice; a more well known alternative for environment setup and packaging can be found
# in the Dockerfile. For more information see https://nixos.org/nix/ and
# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/python.md
#

let
  pkgs_rev = "7f35ed9df40f12a79a242e6ea79b8a472cf74d42"; # (19.03 beta)
  nixpkgs = builtins.fetchTarball {
    name = "nixpkgs-${builtins.substring 0 6 pkgs_rev}";
    url = "https://github.com/NixOS/nixpkgs/archive/${pkgs_rev}.tar.gz";
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "1wr6dzy99rfx8s399zjjjcffppsbarxl2960wgb0xjzr7v65pikz";
  };
in
# with import <nixpkgs> {};
with import nixpkgs {};
with pkgs.python36Packages;
stdenv.mkDerivation {
  name = "impurePythonEnv";
  buildInputs = [
    # these packages are required for virtualenv and pip to work:
    #
    python36Full
    python36Packages.virtualenv
    python36Packages.pip
    python36Packages.pip-tools
    # pipenv
    # the following packages are related to the dependencies of your python
    # project.
    # In this particular example the python modules listed in the
    # requirements.tx require the following packages to be installed locally
    # in order to compile any binary extensions they may require.
    #
    gcc6
    glibcLocales # for click+python3
    libxml2
    ncurses # needed by uWSGI
    openssl
    pcre
    pyre # for typechecking
    (uwsgi.override { plugins = [ "python3" ]; })
    zlib
  ];
  src = null;
  shellHook = ''
    # set SOURCE_DATE_EPOCH so that we can use python wheels
    SOURCE_DATE_EPOCH=$(date +%s)
    export LANG=en_US.UTF-8
    virtualenv venv
    export PATH=$PWD/venv/bin:$PATH
    export PYTHONPATH=$PWD
    export LD_LIBRARY_PATH=${libxml2}/lib:${gcc6.cc.lib}/lib:$LD_LIBRARY_PATH
    export C_INCLUDE_PATH="${libxml2}/include/libxml2"
    pip install pipenv
    pipenv --three install --dev
    export FLASK_APP=app.py
    export FLASK_DEBUG=1
    source private_vars.sh
    source $(pipenv --venv)/bin/activate
  '';
}

# For C_INCLUDE_PATH: :${libxslt}/include/libxslt

#    
#
# Now you can run the following command to start the server:
#
# uwsgi --http-socket :8000 -w wsgi -t 3000 --processes 8 --threads 1 -M --async 100 --ugreen --manage-script-name