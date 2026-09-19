{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  chromium,
}:

let
  version = "0.38.1";
  sources = {
    x86_64-linux = {
      asset = "agent-browser-linux-x64";
      hash = "sha256-UQAUmhkDIRyIneTlRb822QgDdAzqT5mqImUWSfkgXqE=";
    };
    aarch64-linux = {
      asset = "agent-browser-linux-arm64";
      hash = "sha256-k3sxXuB2Hopi95UN3P75s9PY6NXrnJ0r+eI+VyVmRRE=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "agent-browser";
  inherit version;

  src = fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/agent-browser"
    wrapProgram "$out/bin/agent-browser" \
      --set-default AGENT_BROWSER_EXECUTABLE_PATH "${chromium}/bin/chromium"
    runHook postInstall
  '';

  meta = {
    description = "Fast browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    changelog = "https://github.com/vercel-labs/agent-browser/releases/tag/v${version}";
    license = lib.licenses.asl20;
    mainProgram = "agent-browser";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
