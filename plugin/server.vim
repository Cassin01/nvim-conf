function s:handle(req) abort
  if a:req.method ==? 'POST'
    return {
    \   'status': 200,
    \   'status_text': 'OK',
    \   'body': execute(a:req.body),
    \ }
  endif
  return {
  \   'status': 404,
  \   'status_text': 'Not Found',
  \   'body': json_encode(a:req),
  \ }
endfunction

function s:parse_request1(msg) abort
  let req = {}
  let matched = matchlist(a:msg, '^\v(.{-})\r\n\r\n(.*)')[1 : 2]
  let [header_block, body] = matched[1 : 2]
  let start_line = split(header_block, "\r\n")[0]
  let req.method = split(start_line, '\s\+')[0]
  let req.body = body
  return req
endfunction

function s:parse_body(msg) abort
  let flag = v:false
  let ret = []
  for m in a:msg
    if flag
      let ret = add(ret, m)
    endif
    if m =~ '^\r$'
      let flag = v:true
    endif
  endfor
  return join(ret, "\n")
endfunction


function s:parse_request(msg) abort
  let req = {}
  let req.method = split(a:msg[0], '\s\+')[0]

  let req.body = s:parse_body(a:msg)
  return req
endfunction

function s:out_cb(job_id, data, event) abort
  try
    let req = s:parse_request(a:data)
    let res = s:handle(req)
  catch
    let res = {
    \   'status': 400,
    \   'status_text': 'Bad Request',
    \   'body': v:exception,
    \ }
  endtry

  let response = join([
  \   printf('HTTP/1.1 %d %s', res.status, res.status_text),
  \   'Content-Length: ' .. len(res.body),
  \   '',
  \   res.body,
  \ ], "\r\n")

  call luaeval('vim.api.nvim_chan_send(unpack(_A))', [a:job_id, response])
endfunction

function s:start(port) abort
  let job = jobstart(['ncat', '-lkp', a:port], {
  \   'on_stdout': function('s:out_cb'),
  \ })
endfunction

call s:start(11111)
