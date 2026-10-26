{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  chromium,
}:

let
  version = "0.39.4";
  sources = {
    x86_64-linux = {
      asset = "agent-browser-linux-x64";
      hash = "sha256-qoLI7oGji4rZumGvAs7W3Lu4rzbdiytHk4QXf4qgd6Y=";
    };
    aarch64-linux = {
      asset = "agent-browser-linux-arm64";
      hash = "sha256-kitg29n1yLXA85tFO/6Mv2G4Or1Ic0QCilCOjE3KeIM=";
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
