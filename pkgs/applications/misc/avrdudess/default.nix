{ stdenv, fetchurl, unzip, mono, avrdude, gtk2, xdg_utils }:

stdenv.mkDerivation rec {
  name = "avrdudess-2.2.20140102";

  src = fetchurl {
    url = "http://blog.zakkemble.co.uk/download/avrdudess_20140102.zip";
    sha256 = "18llpvjsfhypzijrvfbzmcg3g141f307mzsrg11wcdxh9syxqak6";
  };

  buildInputs = [ unzip ];

  phases = [ "buildPhase" ];

  buildPhase = ''
    mkdir -p "$out/avrdudess"
    mkdir -p "$out/bin"

    unzip "$src" -d "$out/avrdudess"

    cat >> "$out/bin/avrdudess" << __EOF__
    #!${stdenv.shell}
    export LD_LIBRARY_PATH="${stdenv.lib.makeLibraryPath [gtk2 mono]}"
    # We need PATH from user env for xdg-open to find its tools, which
    # typically depend on the currently running desktop environment.
    export PATH="${stdenv.lib.makeBinPath [ avrdude xdg_utils ]}:\$PATH"

    # avrdudess must have its resource files in its current working directory
    cd $out/avrdudess && exec ${mono}/bin/mono "$out/avrdudess/avrdudess.exe" "\$@"
    __EOF__

    chmod a+x "$out/bin/"*
  '';

  meta = with stdenv.lib; {
    description = "GUI for AVRDUDE (AVR microcontroller programmer)";
    homepage = https://github.com/zkemble/AVRDUDESS;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.bjornfor ];
  };
}
