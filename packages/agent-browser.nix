{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  chromium,
}:

let
  version = "0.42.0";
  sources = {
    x86_64-linux = {
      asset = "agent-browser-linux-x64";
      hash = "sha256-tp4PXqdty1H4912mvLh8f02B95tXOPHwi9EhtRyz3Fc=";
    };
    aarch64-linux = {
      asset = "agent-browser-linux-arm64";
      hash = "sha256-ohmxAlHs2F5Xh9ESbclp2SasjS3qMl+dlEE5B6iFb0A=";
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
