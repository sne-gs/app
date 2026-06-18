pub const Handler = enum {
    root,
    add,
    delete,
    toggle,
};

pub const HandlerId = union(enum) {
    global: Handler,
};
