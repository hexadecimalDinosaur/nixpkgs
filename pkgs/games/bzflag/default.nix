{
  stdenv,
  lib,
  fetchurl,
  pkg-config,
  curl,
  SDL2,
  libGLU,
  libGL,
  glew,
  ncurses,
  c-ares,
  Carbon,
  CoreServices,
}:

stdenv.mkDerivation rec {
  pname = "bzflag";
  version = "2.4.28";

  src = fetchurl {
    url = "https://download.bzflag.org/${pname}/source/${version}/${pname}-${version}.tar.bz2";
    sha256 = "sha256-XdOkqSupNOYglUEjrrtL8FrSDPP/dE/U4ejHI7xcq80=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs =
    [
      curl
      SDL2
      libGLU
      libGL
      glew
      ncurses
      c-ares
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      Carbon
      CoreServices
    ];

  meta = with lib; {
    description = "Multiplayer 3D Tank game";
    homepage = "https://bzflag.org/";
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
    maintainers = [ ];
  };
}
