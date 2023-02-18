-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.
local http = require "resty.http"
local base64 = require "ngx.base64"
--assert(ngx.get_phase() == "timer", "The world is coming to an end!")

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------



local plugin = {
  PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}

local PLUGIN_NAME = "tmim-forward-proxy"

-- do initialization here, any module level code runs in the 'init_by_lua_block',
-- before worker processes are forked. So anything you add here will run once,
-- but be available in all workers.



-- handles more initialization, but AFTER the worker process has been forked/created.
-- It runs in the 'init_worker_by_lua_block'
function plugin:init_worker()

  -- your custom code here
  kong.log.debug("saying hi from the 'init_worker' handler")

end --]]



--[[ runs in the 'ssl_certificate_by_lua_block'
-- IMPORTANT: during the `certificate` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:certificate(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'certificate' handler")

end --]]



--[[ runs in the 'rewrite_by_lua_block'
-- IMPORTANT: during the `rewrite` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:rewrite(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'rewrite' handler")

end --]]



-- runs in the 'access_by_lua_block'
function plugin:access(plugin_conf)

  -- your custom code here
  kong.log.inspect(plugin_conf)   -- check the logs for a pretty-printed config!
  -- kong.service.request.set_header(plugin_conf.request_header, "this is on a request")


  -- get the current request headers
  local headers = ngx.req.get_headers()

  -- set the headers to send to the authentication proxy
  local httpc = http.new()
  local auth_header = "Basic " .. base64.encode(plugin_conf.username .. ":" .. plugin_conf.password)
  local res, err = httpc:request_uri(plugin_conf.proxy_url, {
    method = ngx.req.get_method(),
    headers = ngx.req.get_headers(),
    body = ngx.req.get_body_data(),
    ssl_verify = false,
    keepalive = true,
    headers = {
      ["Proxy-Authorization"] = auth_header
    }
  })
  if err then
    ngx.log(ngx.ERR, "Failed to send request via proxy: ", err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end
  ngx.status = res.status
  ngx.say(res.body)
end
-- return our plugin object
return {
  [PLUGIN_NAME] = {
    access = access,
  },
  fields = {
    proxy_url = { type = "url", required = true },
    username = { type = "string", required = true },
    password = { type = "string", required = true },
  }
}

