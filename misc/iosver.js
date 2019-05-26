const VERSION_CHECK_SUPPORTED = "Your iOS version is supported! &#x1f60a;";
const VERSION_CHECK_NEEDS_UPGRADE = "Requires at least iOS %s &#x1f615;";
const VERSION_CHECK_UNCONFIRMED = "Not yet tested on iOS %s &#x1f601;";
const VERSION_CHECK_UNSUPPORTED = "Only compatible with iOS %s to %s";

(function (document) {
	"use strict";

	function setMessage(m) {
		document.getElementById("pt").innerHTML = m;
	}

	function toNum(bits) {
		return (10000 * parseInt(bits[0])) + parseInt((100 * (bits[1] ? bits[1] : 0))) + parseInt(bits[2] ? bits[2] : 0);
	}

	function parseVersionString(version) {
		var bits = version.split(".");
		return toNum(bits);
	}

	function compareVersions(one, two) {
		var two_ = toNum(two);
		return one != two_ ? (one > two_ ? 1 : -1) : 0;
	}

	var prerequisite = document.getElementById("prerequisite"),
		version = navigator.appVersion.match(/CPU( iPhone)? OS (\d+)_(\d+)(_(\d+))? like/i);

	if (!prerequisite) {
		return;
	}

	var minString = prerequisite.dataset.minIos;
	var maxString = prerequisite.dataset.maxIos;

	var minVersion = parseVersionString(minString);
	var maxVersion = maxString ? parseVersionString(maxString) : null;
	var message = null;

	if (version) {
		var osVersion = [version[2], version[3], version[4] ? version[5] : 0];
		var osString = osVersion[0] + "." + osVersion[1] + (osVersion[2] && osVersion[2] != 0 ? "." + osVersion[2] : "");
		message = VERSION_CHECK_SUPPORTED;
		if (compareVersions(minVersion, osVersion) == 1) {
			message = VERSION_CHECK_NEEDS_UPGRADE.replace("%s", minString);
		} else if (maxVersion && compareVersions(maxVersion, osVersion) == -1) {
			if ("unsupported" in prerequisite.dataset) {
				message = VERSION_CHECK_UNSUPPORTED.replace("%s", minString).replace("%s", maxString);
			} else {
				message = VERSION_CHECK_UNCONFIRMED.replace("%s", osString);
			}
		}
		setMessage(message);
	}
})(document);
