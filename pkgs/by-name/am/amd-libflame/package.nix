{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gfortran,
  python3,
  amd-blis,
  aocl-utils,

  withOpenMP ? true,
  blas64 ? false,
  withAMDOpt ? true,
}:

stdenv.mkDerivation rec {
  pname = "amd-libflame";
  version = "5.0";

  src = fetchFromGitHub {
    owner = "amd";
    repo = "libflame";
    rev = version;
    hash = "sha256-Shsv5Zd59FN5tq1LY7QqPRtAHEysHIVbPeKIIZ/2eMw=";
  };

  postPatch = ''
    patchShebangs build

    # Enforce reproducible build compiler flags
    substituteInPlace CMakeLists.txt --replace '-mtune=native' ""
  '';

  env.NIX_CFLAGS_COMPILE = "-Wno-implicit-function-declaration";

  passthru = {
    inherit blas64;
  };

  nativeBuildInputs = [
    cmake
    gfortran
    python3
  ];

  buildInputs = [
    amd-blis
    aocl-utils
  ];

  cmakeFlags =
    [
      "-DLIBAOCLUTILS_LIBRARY_PATH=${lib.getLib aocl-utils}/lib/libaoclutils${stdenv.hostPlatform.extensions.sharedLibrary}"
      "-DLIBAOCLUTILS_INCLUDE_PATH=${lib.getDev aocl-utils}/include"
      "-DENABLE_BUILTIN_LAPACK2FLAME=ON"
      "-DENABLE_CBLAS_INTERFACES=ON"
      "-DENABLE_EXT_LAPACK_INTERFACE=ON"
    ]
    ++ lib.optional (!withOpenMP) "-DENABLE_MULTITHREADING=OFF"
    ++ lib.optional blas64 "-DENABLE_ILP64=ON"
    ++ lib.optional withAMDOpt "-DENABLE_AMD_OPT=ON";

  postInstall = ''
    ln -s $out/lib/libflame.so $out/lib/liblapack.so.3
    ln -s $out/lib/libflame.so $out/lib/liblapacke.so.3
  '';

  meta = with lib; {
    description = "LAPACK-compatible linear algebra library optimized for AMD CPUs";
    homepage = "https://developer.amd.com/amd-aocl/blas-library/";
    license = licenses.bsd3;
    maintainers = [ maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
}
