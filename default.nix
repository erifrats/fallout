with import ./pkgs;

stdenv.mkDerivation {
  name = "stargate";

  src = ./src;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib

    cp -r $src/. $out/lib

    chmod +x $out/lib/stargate/main.sh

    makeWrapper $out/lib/stargate/main.sh $out/bin/stargate \
      --suffix PATH : ${lib.makeBinPath [ gum disko git ]}
  '';
}
