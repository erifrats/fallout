{ writeShellScriptBin }:

writeShellScriptBin "stargate" ''
  exec bash /src/src/stargate/main.sh "$@"
''
