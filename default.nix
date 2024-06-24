with import ./pkgs;

stdenv.mkDerivation {
  name = "starship";

  src = ./src;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib

    cp -r $src/. $out/lib

    chmod +x $out/lib/starship/main.sh

    makeWrapper $out/lib/starship/main.sh $out/bin/starship \
      --suffix PATH : ${lib.makeBinPath [ gum disko git ]}
  '';
}
