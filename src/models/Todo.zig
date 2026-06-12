const sl = @import("sqlite");

pub const Todo = struct {
    id: i64,
    title: sl.Text,
    completed: i64,

    pub fn isCompleted(self: Todo) bool {
        return self.completed != 0;
    }
};
