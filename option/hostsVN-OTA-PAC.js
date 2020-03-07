var DIRECT = "DIRECT";
var PROXY = "PROXY 127.0.0.1:80";
var blacklist = {"appldnld.apple.com":1,"appldnld.apple.com.akadns.net":1,"appldnld.g.aaplimg.com":1,"mesu.apple.com":1,"mesu-cdn.apple.com.akadns.net":1,"mesu-cdn.origin-apple.com.akadns.net":1,"mesu.g.aaplimg.com":1,"gdmf.apple.com":1,"gdmf.apple.com.akadns.net":1,"ocsp.apple.com":1};
function FindProxyForURL(url, host) {
  host = host.toLowerCase();
  for (i = 0; i < 30; i++) {
    if (blacklist[host]) {
      return PROXY;
    }
    var index = host.indexOf(".");
    if (index == -1) {
      break;
    } else {
      host = host.substring(index + 1);
    }
  }
  return DIRECT;
}
