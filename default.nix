{ stdenv }:

stdenv.mkDerivation {
  name = "stargate";
  src = ./src;

  propagatedBuildInputs = [ ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/stargate/main.sh $out/bin/stargate
    chmod +x $out/bin/stargate
  '';
}
