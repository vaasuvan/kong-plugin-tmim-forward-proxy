return {
  no_consumer = true,
  fields = {
    proxy_url = { type = "url", required = true },
    username = { type = "string", required = true },
    password = { type = "string", required = true },
  },
  self_check = function(schema, plugin_t, dao, is_updating)
    -- Check if plugin configuration is valid
    if not plugin_t.username or not plugin_t.password or not plugin_t.proxy_url then
      return false, "You need to specify a proxy_url, username and password"
    end
    return true
  end
}
