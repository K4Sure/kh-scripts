Quick: show swatches (TTY)
  bin/cml palette edge_base

Pipe-friendly (plain map)
  bin/cml palette edge_base | sed -n '1,40p'

Force alphabetical order
  ORDER=az bin/cml palette edge_base

Strict validation
  The wrapper now fails (non-zero exit) on malformed hex values.
