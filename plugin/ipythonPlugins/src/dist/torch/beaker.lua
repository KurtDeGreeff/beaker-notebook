-- Copyright 2014 TWO SIGMA OPEN SOURCE, LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--        http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local beaker = {}

curle = require 'curle'
json = require 'json'

local sessionId

local coreUrl = '127.0.0.1:' .. os.getenv('beaker_core_port')
local coreAuth = {user = 'beaker', password = os.getenv('beaker_core_password')}

function beaker.setSession (id)
  beaker.sessionId = id
end

function beaker.getSession ()
  return beaker.sessionId
end

function beaker.get (var)
  reply = curle.get({url = 'http://' .. coreUrl .. '/rest/namespace/get',
                     auth = coreAuth, query = {name = var, session = beaker.sessionId}})
  reply = json.decode(reply)
  if not reply.defined then
    error('name \'' .. var .. '\' is not defined in notebook namespace')
  end
  return reply.value
end

function beaker.set4 (var, val, unset, sync)
  args = {name = var, session = beaker.sessionId, sync = sync}
  if not unset then
    args.value = json.encode(val)
  end
  reply = curle.post({url = 'http://' .. coreUrl .. '/rest/namespace/set',
                      auth = coreAuth, form = args})
  return reply
end

function beaker.set (var, val)
  beaker.set4(var, val, false, true)
end

return beaker
