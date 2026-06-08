// V0

// hello_button.zv

<button(text: []u8) onClick={(el) => {
  el.swap(<div>Hello World!</div>);
}}>{text}</button>

// or even shorter

<button(text: []u8) onClick={el => el.swap(<div>Hello World!</div>)}>{text}</button>

// would transform to:

<button hx-post="/clicked" hx-swap="outerHTML">
  {text}
</button>

fn clickHandler(ctx: *zs.Context) zs.Response {
    _ = ctx;
    return zs.Response.init(.ok, "<div>Hello, World!</div>", "text/html");
}

// question: do we need another step to transform all the templated buttons into the html ones at comptime?

<HelloButton text="Click to swap"/>
<HelloButton text="And another"/>

// question: how to decompose routes in a larger component tree?

// btn_list.zv

const Button = import("button.zv").Button;

<ul>
  {for (btns) |btn| {
    <li><Button text={btn.text} /></li>
  }}
</ul>

// V0.1

const zui = import("zui");
const button = import("button.zig");

pub fn app() {
  return zui.div(
    zui.span(button("Hello!"))
  )
}

pub fn someJsonEndpoint() { ... }

pub fn main() !void {
  var server = try zs.Server(Dispatch).init(allocator);
  server.setPort(3001);
  try server.addRoute(.GET, "/json", .someJsonEndpoint);
  try server.addApp(.app);
  try server.start();
}

// V0.2

const zui = import("zui");
const button = import("button.zig");

pub fn app() {
  return zui.div(
    zui.span(button("Hello!"))
  )
}

pub fn someJsonEndpoint() { ... }

pub fn main() !void {
  var server = try zs.Server(Dispatch).init(allocator);
  server.setPort(3001);
  try server.addRoute(.GET, "/json", .someJsonEndpoint);
  try zui.createApp(server, .app);
  try server.start();
}
