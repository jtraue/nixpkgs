{
  lib,
  buildNpmPackage,
  src,
  version,
}:

buildNpmPackage {
  inherit src version;
  pname = "photoprism-frontend";

  postPatch = ''
    cd frontend
  '';

  npmDepsHash = "sha256-3FcMIT29hXBIV1S/GvGqFRiT+5va1lsC8Hfs3roIAwQ=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r ../assets $out/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://photoprism.app";
    description = "Photoprism's frontend";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ benesim ];
  };
}
