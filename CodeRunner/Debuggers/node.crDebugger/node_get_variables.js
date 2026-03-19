let fs = require('fs')
let tmpFile = process.env["CR_TMPDIR"]+'/node_debug_vars_'+process.env["CR_RUNID"]+'.json'
if (fs.existsSync(tmpFile)) {
	fs.unlinkSync(tmpFile)
}
let objectIds = []
let promiseCount = 0
let vars = []
let scopes = bt[0].scopeChain
for (let i = 0; i < scopes.length; i++) {
	let scope = scopes[i]
	Runtime.getProperties({
		objectId:scope.object.objectId
	}).then(({ result }, err) => {
		result = result.filter(v => {
			if (v["name"].startsWith("__")) {
				v["priority"] = -1
			}
			if (["exports", "module"].indexOf(v["name"]) != -1) {
				v["priority"] = -1
			}
			if (v["value"] && v["value"]["type"] === "function") {
				v["priority"] = -1
			}
			if (scope.type === "global" && v["name"] != "global") {
				return false
			}
			return true
		});
		if (scope.type === "global") {
			vars = result.concat(vars)
		} else {
			vars = vars.concat(result)
		}
		let mapFunc = function(obj, depth = 0) {
			if (obj.value !== undefined && obj.value.value === undefined && obj.value.objectId !== undefined && objectIds.indexOf(obj.value.objectId) == -1 && obj.value.type !== "function") {
				objectIds.push(obj.value.objectId)
				promiseCount++;
				let prom = Runtime.getProperties({objectId:obj.value.objectId}).then(({ result }, err) => {
					result = result.filter(v => {
						if (v["name"].startsWith("__")) {
							v["priority"] = -1
							return true
						}
						if (["hasOwnProperty", "isPrototypeOf", "propertyIsEnumerable", "toSource", "toString", "unwatch", "valueOf", "watch", "toLocaleString", "eval", "constructor", "Symbol(Symbol.toStringTag)"].indexOf(v["name"]) != -1) {
							v["priority"] = -1
							return true
						}
						if (v["value"]) {
							if (v["value"]["type"] === "function") {
								v["priority"] = -1
								return true
							}
						}
						if (obj["value"]["subtype"] == "array" || obj["value"]["subtype"] == "typedarray") {
							if (parseInt(v["name"])+"" !== v["name"]+"") {
								v["priority"] = -1
								return true
							}
						}
						if (scope.type === "global" && v["name"] === "global") {
							return false
						}
						return true
					});
					if (scope.type === "global") {
						obj.kind = "global"
					}
					if (typeof __cr_variables_depth === "undefined" || depth <= __cr_variables_depth) {
						for (let i = 0; i < result.length; i++) {
							if (result[i].enumerable === true) {
								mapFunc(result[i], depth+1)
							}
						}
						obj.value.value = result
						obj.value.shouldRecurse = true
					} else {
						obj.value.value = [{"name":"..."}]
						obj.value.shouldRecurse = false
					}
					promiseCount--
					if (promiseCount == 0) {
						fs.writeFileSync(tmpFile, JSON.stringify(vars), {}, function(err) {
							
						})
					}
				}).catch(function (reason) {
					promiseCount--
					if (promiseCount == 0) {
						fs.writeFileSync(tmpFile, JSON.stringify(vars), {}, function(err) {
							
						})
					}
				})
			}
			return obj
		}
		if (result.length > 0) {
			for (let i = 0; i < result.length; i++) {
				mapFunc(result[i], 0)
			}
		} else {
			fs.writeFileSync(tmpFile, '[]', {}, function(err) {})
		}
		return true;
	}).catch(function (reason) {
		promiseCount--
		if (promiseCount == 0) {
			fs.writeFileSync(tmpFile, JSON.stringify(vars), {}, function(err) {
				
			})
		}
	})
}
if (scopes.length == 0) {
	fs.writeFileSync(tmpFile, '[]', {}, function(err) {})
}