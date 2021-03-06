{ stdenv, fetchPypi, buildPythonPackage, pythonAtLeast
, more-itertools, six, setuptools_scm, setuptools-scm-git-archive
, pytest, pytestcov, portend, pytest-testmon, pytest-mock
, backports_unittest-mock, pyopenssl, requests, trustme, requests-unixsocket
, backports_functools_lru_cache }:

let inherit (stdenv) lib; in

buildPythonPackage rec {
  pname = "cheroot";
  version = "6.5.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "427e7e3ce51ad5a6e5cf953252b5782d5dfbeb544c09910634971bc06df6621b";
  };

  patches = [ ./tests.patch ];

  nativeBuildInputs = [ setuptools_scm setuptools-scm-git-archive ];

  propagatedBuildInputs = [ more-itertools six backports_functools_lru_cache ];

  checkInputs = [ pytest pytestcov portend backports_unittest-mock pytest-mock pytest-testmon pyopenssl requests trustme requests-unixsocket ];

  # Disable doctest plugin because times out
  # Disable xdist (-n arg) because it's incompatible with testmon
  # Deselect test_bind_addr_unix on darwin because times out
  # Deselect test_http_over_https_error on darwin because builtin cert fails
  # Disable warnings-as-errors because of deprecation warnings from socks on python 3.7
  checkPhase = ''
    substituteInPlace pytest.ini --replace "--doctest-modules" "" --replace "-n auto" ""
    ${lib.optionalString (pythonAtLeast "3.7") "sed -i '/warnings/,+2d' pytest.ini"}
    pytest -k 'not tls' ${lib.optionalString stdenv.isDarwin "--deselect=cheroot/test/test_ssl.py::test_http_over_https_error --deselect=cheroot/test/test_server.py::test_bind_addr_unix"}
  '';

  # Some of the tests use localhost networking.
  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    description = "High-performance, pure-Python HTTP";
    homepage = https://github.com/cherrypy/cheroot;
    license = licenses.mit;
  };
}
