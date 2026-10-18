require "protocol/http"

bodyless = Protocol::HTTP::Request["GET", "/"]
p [:bodyless_body, bodyless.body]
p [:bodyless_close, bodyless.close]
p [:bodyless_rewind, bodyless.rewind!]

buffered = Protocol::HTTP::Request["POST", "/", body: ["a", "b"]]
p [:buffered_body, buffered.body.class, buffered.body?]
p [:buffered_rewind, buffered.rewind!]
buffered.close
p [:after_close_body, buffered.body]
p [:after_close_read, buffered.read]
p [:after_close_rewind, buffered.rewind!]
p [:after_close_retry, buffered.retry!]

streaming = Protocol::HTTP::Request["POST", "/", body: Protocol::HTTP::Body::Writable.new]
p [:streaming_rewind, streaming.rewind!]
streaming.close
p [:streaming_after_close, streaming.body]
