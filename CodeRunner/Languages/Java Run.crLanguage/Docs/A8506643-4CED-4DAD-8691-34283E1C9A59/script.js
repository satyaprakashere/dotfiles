/*
  Use this script to customize documentation lookups in CodeRunner.
  The script is loaded along with the web page when performing a lookup.
  The variable CodeRunnerDocsContext will contain information about the lookup.
  Most fields may also be used in the lookup URL, e.g. {query}, {lang}, etc
  Some important fields include:
  CodeRunnerDocsContext = {
    "query": the documentation search query,
    "lang": language name based on the current editor scope (if in doubt, use this),
    "languageName": active CodeRunner language name,
    "codeCompletionObject": if set, the code completion that invoked the lookup,
    "editorObject": if set, the editor context that invoked the lookup,
    "scope": the editor syntax scope for the current document
  }
  View the full contents of the variable using the code below:
    alert(JSON.stringify(CodeRunnerDocsContext, null, '\t'));

  You may also optionally define the function CodeRunnerDocsContextUpdate(),
  which will be called for consecutive lookups instead of reloading the entire
  page, given that the function returns true.
*/

function findJavaIndexPage() {
	if (CodeRunnerDocsContext["hasNavigated"]) {
		return false
	}
	var match = window.location.href.match(/^https:\/\/docs.oracle.com\/javase\/(\d+)\/docs\/api\/index/)
	if (!match) {
		return false
	}
	if (CodeRunnerDocsContext && CodeRunnerDocsContext["codeCompletionObject"]) {
		var docURL = CodeRunnerDocsContext["codeCompletionObject"]["doc"]
		if (docURL) {
			var link = "https://docs.oracle.com/javase/"+match[1]+"/docs/api/"+docURL
			window.location.replace(link)
			return false
		}
	}
	var query = CodeRunnerDocsContext["query"]
	if (query.length > 0) {
		var keyword = getTerms(query)["keyword"]
		if (keyword.length > 0) {
			var first = keyword.toLowerCase().charCodeAt(0)
			var page = 0
			if (first == 95) {
				page = 27
			} else if (first >= 97 && first <= 122) {
				page = first-96
			}
			if (page) {
				var link = "https://docs.oracle.com/javase/"+match[1]+"/docs/api/index-files/index-"+page+".html"
				if (link != window.location.href) {
					window.location.replace(link)
				}
				return true
			}
		}
	}
	document.body.innerHTML = "No Results"
	return true
}

function getTerms(query) {
	var terms = {"terms":[]}
	var split = query.split(" ")
	while (split.length > 1) {
		var empty = split.indexOf("")
		if (empty == -1) break
			split.splice(empty, 1)
	}
	var dotsplit = split[0].split(".")
	while (dotsplit.length > 1) {
		if (dotsplit[dotsplit.length-1].length == 0) {
			dotsplit.splice(dotsplit.length-1, 1)
		} else {
			break
		}
	}
	terms["keyword"] = dotsplit[dotsplit.length-1]
	if (dotsplit.length > 1) {
		var dotstring = ""
		for (var i = 0; i < dotsplit.length-1; i++) {
			if (dotsplit[i].length > 0) {
				dotstring += dotsplit[i]+"."
			}
		}
		if (dotstring.length > 1) {
			dotstring = dotstring.substr(0, dotstring.length-1)
			split.splice(0, 1, dotstring)
		} else {
			split.splice(0, 1)
		}
	} else {
		split = split.splice(1, split.length-1)
	}
	terms["terms"] = split
	return terms
}

function CodeRunnerDocsContextUpdate() {
	if (findJavaIndexPage() == false) {
		var dl = document.querySelectorAll("dl")
		for (var i = 0; i < dl.length; i++) {
			dl[i].style.display = "block"
		}
		return
	}
	var query = CodeRunnerDocsContext["query"]
	if (query.length > 0) {
		window.scrollTo(0, 0)
		var dl = document.querySelector("dl.visibleItems")
		if (!dl) {
			dl = document.createElement("dl")
			dl.classList.add("visibleItems")
			var firstDl = document.getElementsByTagName("dl")[0]
			firstDl.parentNode.insertBefore(dl, firstDl)
		}
		var terms = getTerms(query)
		var keyword = terms["keyword"]
		var lowerCaseKeyword = keyword.toLowerCase()
		var array = document.querySelectorAll("dt > span, dt > a > span, dt > a > b")
		var visibleItems = []
		for (var i = 0; i < array.length; i++) {
			var parent = array[i].parentNode
			while (parent && parent.nodeName != "DT") {
				parent = parent.parentNode
			}
			var text = array[i].textContent
			if (text.toLowerCase().startsWith(lowerCaseKeyword)) {
				var score = 0
				if (text == keyword) {
					score += 30000
				} else if (text.toLowerCase() == lowerCaseKeyword) {
					score += 20000
				} else {
					if (text.startsWith(keyword)) {
						score += 10000
					}
					if (text.substr(keyword.length, 1) == "(") {
						score += 20000
					}
				}
				var parentString = parent.textContent
				var lowerCaseParentString = parentString.toLowerCase()
				var lowerCaseTerms = terms["terms"].map(function (elt, i) {
					return elt.toLowerCase()
				})
				for (var j = 0; j < terms["terms"].length; j++) {
					var index = lowerCaseParentString.indexOf(lowerCaseTerms[j])
					if (index != -1) {
						var term = terms["terms"][j]
						if (parentString.substr(index, term.length) == term) {
							score += 1000
						} else {
							score += 800
						}
					}
				}
				if (parentString.indexOf(" - Class in ") != -1) {
					score += 10
				} else if (parentString.indexOf(" - Interface in ") != -1) {
					score += 8
				} else if (parentString.indexOf(" - Method in ") != -1) {
					score += 6
				} else if (parentString.indexOf(" - Constructor for class ") != -1) {
					score += 6
				} else if (parentString.indexOf(" - Static method in ") != -1) {
					score += 6
				}
				if (parentString.indexOf(" java.lang.") != -1) {
					score += 3
				} else if (parentString.indexOf(" java.") != -1) {
					score += 1
				}
				visibleItems.push({"item":parent, "text":text, "score":score, "index":i})
				var sibling = parent.nextElementSibling
				dl.appendChild(parent)
				if (sibling.nodeName == "DD") {
					dl.appendChild(sibling)
				}
			} else {
				parent.style.display = "none"
				var sibling = parent.nextElementSibling
				if (sibling.nodeName == "DD") {
					sibling.style.display = "none"
				}
			}
		}
		visibleItems.sort(function (a, b) {
			var score1 = a["score"]
			var score2 = b["score"]
			if (score1 < score2) {
				return 1
			} else if (score1 > score2) {
				return -1
			}
			var compare = a["text"].localeCompare(b["text"])
			if (compare != 0) {
				return compare
			}
			if (a["index"] < b["index"]) {
				return -1
			} else if (a["index"] > b["index"]) {
				return 1
			}
			return 0
		})
		for (var idx = 0; idx < visibleItems.length; idx++) {
			var item = visibleItems[idx]["item"]
			var sibling = item.nextElementSibling
			if (sibling.nodeName != "DD") {
				sibling = false
			}
			if (idx > 0) {
				var next = visibleItems[idx-1]["item"].nextElementSibling
				while (next && next.nodeName != "DT") {
					next = next.nextElementSibling
				}
				if (!item.isSameNode(next)) {
					item.parentNode.insertBefore(item, next)
					if (sibling) {
						item.parentNode.insertBefore(sibling, item.nextElementSibling)
					}
				}
			}
			item.style.display = "block"
			if (sibling) {
				sibling.style.display = "block"
			}
		}
		if (visibleItems.length == 0) {
			var nothingFound = document.querySelector("h2.nothingfound")
			if (!nothingFound) {
				nothingFound = document.createElement("h2")
				nothingFound.classList.add("nothingfound")
				nothingFound.innerHTML = "No Results"
				dl.appendChild(nothingFound)
			}
			nothingFound.style.display = "block"
		} else {
			var nothingFound = document.querySelector("h2.nothingfound")
			if (nothingFound) {
				nothingFound.style.display = "none"
			}
		}
	}
	return true
}

window.addEventListener('load', function (e) {
	CodeRunnerDocsContextUpdate()
})

window.addEventListener('DOMContentLoaded', function (e) {
	for (var e of document.querySelectorAll("h2[title^=Class], h2[title^=Interface], h2[title^=Enum]")) {
		if (e.textContent.startsWith("Class ")) {
			e.dataset.coderunnerTocTitle = e.textContent.substr(6)
			e.dataset.coderunnerTocSymbolKind = "class";
		} else if (e.textContent.startsWith("Interface ")) {
			e.dataset.coderunnerTocTitle = e.textContent.substr(10)
			e.dataset.coderunnerTocSymbolKind = "interface";
		} else if (e.textContent.startsWith("Enum ")) {
			e.dataset.coderunnerTocTitle = e.textContent.substr(5)
			e.dataset.coderunnerTocSymbolKind = "enum";
		}
	}
	var toc = function (elements, symbolKind) {
		for (var e of elements) {
			var h4 = e.previousElementSibling
			var title = h4.textContent
			var text = e.textContent
			text = text.replace(/[\n\r\s]+/g, ' ')
			text = text.replace(/[\u200B]/g, '')
			if (symbolKind == "method") {
				var i = text.indexOf(title+"(")
				if (i != -1) {
					text = text.substr(i)
					var th = text.search(/\)\s+throws\s+/)
					if (th != -1) {
						text = text.substr(0, th)
					}
					h4.dataset.coderunnerTocTitle = text;
				}
			}
			if (symbolKind) {
				h4.dataset.coderunnerTocSymbolKind = symbolKind;
			}
		}
	}
	toc(document.querySelectorAll("a[name='method.detail'] ~ ul h4 + pre, a[id='method.detail'] ~ ul h4 + pre"), "method");
	toc(document.querySelectorAll("a[name='constructor.detail'] ~ ul h4 + pre, a[id='constructor.detail'] ~ ul h4 + pre"), "method");
	toc(document.querySelectorAll("a[name='field.detail'] ~ ul h4 + pre, a[id='field.detail'] ~ ul h4 + pre"), "field");
	toc(document.querySelectorAll("a[name='enum.constant.detail'] ~ ul h4 + pre, a[id='enum.constant.detail'] ~ ul h4 + pre"), "constant");
})

findJavaIndexPage()
