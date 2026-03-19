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

var CodeRunnerStyleIgnoreMutations = true

window.addEventListener('load', function (e) {
	if (window.location.href.indexOf("/search/") != -1) {
		var headers = document.querySelectorAll("h1, h2, h3, h4, h5, h6")
		for (var i = 0; i < headers.length; i++) {
			headers[i].dataset.coderunnerTocTitle = ""
		}
		var searchResults = document.querySelector("ul.search-results")
		if (searchResults) {
			var observer = new MutationObserver(function (mutation) {
				var results = document.querySelectorAll("ul.search-results p.result-title a")
				var lang = CodeRunnerDocsContext["scope"].startsWith("source.objc") ? "objc" : "swift"
				var query = CodeRunnerDocsContext["query"]
				var escapedQuery = query.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")
				var regex = new RegExp('(\\b|^)('+escapedQuery+')(\\b|$)', 'i')
				var matchedResult = false
				var matchedResultCount = 0
				for (var i = 0; i < results.length; i++) {
					var href = results[i].href.replace(/(\?|&)language=[\w\-]+/, '$1language='+lang)
					if (href == results[i].href) {
						href = href+(href.indexOf("?") != -1 ? "&" : "?")+"language="+lang
					}
					results[i].href = href
					
					if (results[i].textContent.match(regex)) {
						if (matchedResultCount == 0) {
							matchedResult = results[i]
						}
						matchedResultCount++
					}
				}
				if (matchedResultCount == 1 || (matchedResultCount > 1 && CodeRunnerDocsContext["isAutolookup"] == true)) {
					if (CodeRunnerDocsContext["isHistoryItem"] != true) {
						setTimeout(function () {
							window.location.href = matchedResult.href
						}, 700)
					}
				}
			})
			observer.observe(searchResults, { childList: true })
		}
	}
	var symbols = document.querySelectorAll("code.display-name")
	for (var i = 0; i < symbols.length; i++) {
		var symbol = symbols[i].textContent
		symbol = symbol.replace(/^\s*(-|\+)\s+/, '$1')
		var kind = "code"
		if (symbol.startsWith('+') || symbol.startsWith('-') || symbol.startsWith('init')) {
			kind = "method"
		} else if (symbol.startsWith('func ')) {
			symbol = symbol.substring(5)
			kind = "method"
		} else if (symbol.startsWith('class func ')) {
			symbol = symbol.substring(11)
			kind = "method"
		} else if (symbol.startsWith('class ')) {
			symbol = symbol.substring(6)
			kind = "class"
		} else if (symbol.startsWith('var ')) {
			symbol = symbol.substring(4)
			kind = "property"
		} else if (symbol.startsWith('typealias ')) {
			symbol = symbol.substring(10)
			kind = "typealias"
		} else if (symbol.startsWith('struct ')) {
			symbol = symbol.substring(7)
			kind = "struct"
		} else if (symbol.startsWith('enum ')) {
			symbol = symbol.substring(5)
			kind = "enum"
		}
		symbols[i].dataset.coderunnerTocTitle = symbol
		symbols[i].dataset.coderunnerTocSymbolKind = kind
	}
})
