const std = @import("std");
const raylib = @import("raylib");
const raygui = @import("raygui");

const Vector2 = raylib.Vector2;
const Color = raylib.Color;
const Rectangle = raylib.Rectangle;
const KeyboardKey = raylib.KeyboardKey;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const GLOBAL_ALLOCATOR = gpa.allocator();
const BG_COLOR = Color.ray_white;

const BLOCK_WIDTH = 100;
const BLOCK_HEIGHT = 50;
const FONT_SIZE = 10; // Should be a multiple of 10, otherwise it won't scale properly
const PADDING = 10.0;
const OUTPUT_ID: usize = 0b0;
const INPUT_ID: usize = std.math.maxInt(usize);

// TODO: Make colors that contrast each other enough.
const OUTPUT_COLOR = Color.gold;
const INPUT_COLOR = Color.init(128, 212, 255, 255); // Light Blue

const Block = struct {
    type: BlockType,
    position: Vector2 = Vector2.init(PADDING, PADDING),
    size: Vector2 = Vector2.init(BLOCK_WIDTH, BLOCK_HEIGHT),
    color: Color,
    text_color: Color = Color.black,
    text: [*:0]const u8,
    notch_depth: f32 = 10,
    notch_x_offset: f32 = 10,
    notch_width: f32 = 40,

    fn init(block_type: BlockType) Block {
        return Block{ .type = block_type, .color = switch (block_type) {
            .output => OUTPUT_COLOR,
            .middle => Color.green,
            .input => INPUT_COLOR,
        }, .text = switch (block_type) {
            .output => "Output",
            .input => "Input",
            .middle => "TODO",
        } };
    }

    fn init_input() Block {
        return Block{
            .type = BlockType.input,
            .color = INPUT_COLOR,
            .text = "Input",
        };
    }

    fn init_output() Block {
        return Block{
            .type = BlockType.output,
            .color = OUTPUT_COLOR,
            .text = "Output",
        };
    }

    fn draw_top_notch(self: Block) void {
        const block_left = self.position.x;
        const block_top = self.position.y;

        raylib.drawTriangle( //
            Vector2.init(block_left + self.notch_x_offset, block_top), //
            Vector2.init(block_left + self.notch_x_offset, block_top + self.notch_depth), //
            Vector2.init(block_left + self.notch_x_offset + (self.notch_width / 2), block_top + self.notch_depth), //
            self.color //
        );
        raylib.drawTriangle( //
            Vector2.init(block_left + self.notch_x_offset + self.notch_width, block_top), //
            Vector2.init(block_left + self.notch_x_offset + (self.notch_width / 2), block_top + self.notch_depth), //
            Vector2.init(block_left + self.notch_x_offset + self.notch_width, block_top + self.notch_depth), //
            self.color //
        );
        raylib.drawRectangleV(Vector2.init(block_left, block_top), Vector2.init(self.notch_x_offset, self.notch_depth), self.color);
        raylib.drawRectangleV( //
            Vector2.init(block_left + self.notch_x_offset + self.notch_width, block_top), //
            Vector2.init(self.size.x - (self.notch_x_offset + self.notch_width), self.notch_depth), //
            self.color //
        );

        const block_right = self.position.x + self.size.x;
        raylib.drawSplineLinear(&[_]Vector2{ //
            Vector2.init(block_left, block_top), //
            Vector2.init(block_left + self.notch_x_offset, block_top), //
            Vector2.init(block_left + self.notch_x_offset + (self.notch_width / 2), block_top + self.notch_depth), //
            Vector2.init(block_left + self.notch_x_offset + self.notch_width, block_top), //
            Vector2.init(block_right, block_top), //
        }, //
            2.0, Color.black);
    }

    fn draw_bottom_rect(self: Block) void {
        const block_left = self.position.x;
        const block_top = self.position.y;

        raylib.drawRectangleV( //
            Vector2.init(block_left, block_top + self.notch_depth), //
            Vector2.init(self.size.x, self.size.y - self.notch_depth), //
            self.color);

        const block_right = self.position.x + self.size.x;
        const block_bottom = self.position.y + self.size.y;
        raylib.drawSplineLinear(&[_]Vector2{ //
            Vector2.init(block_left, block_top), //
            Vector2.init(block_left, block_bottom), //
            Vector2.init(block_right, block_bottom), //
            Vector2.init(block_right, block_top), //
        }, //
            2.0, Color.black);
    }

    fn draw_top_rect(self: Block) void {
        const block_left = self.position.x;
        const block_top = self.position.y;

        raylib.drawRectangleV(Vector2.init(block_left, block_top), Vector2.init(self.size.x, self.size.y), self.color);

        const block_right = self.position.x + self.size.x;
        const block_bottom = self.position.y + self.size.y;
        raylib.drawSplineLinear(&[_]Vector2{ //
            Vector2.init(block_left, block_bottom), //
            Vector2.init(block_left, block_top), //
            Vector2.init(block_right, block_top), //
            Vector2.init(block_right, block_bottom), //
        }, //
            2.0, Color.black);
    }

    fn draw_bottom_notch(self: Block) void {
        const block_left = self.position.x;
        const block_top = self.position.y;
        const block_bottom = block_top + self.size.y;

        raylib.drawTriangle( //
            Vector2.init(block_left + self.notch_x_offset, block_bottom), //
            Vector2.init(block_left + self.notch_x_offset + (self.notch_width / 2), block_bottom + self.notch_depth), //
            Vector2.init(block_left + self.notch_x_offset + self.notch_width, block_bottom), //
            self.color //
        );

        raylib.drawRectangleV( //
            Vector2.init(block_left, block_top + self.notch_depth), //
            Vector2.init(self.size.x, self.size.y - self.notch_depth), //
        // self.color);
            self.color);

        const block_right = self.position.x + self.size.x;
        raylib.drawSplineLinear(&[_]Vector2{ //
            Vector2.init(block_left, block_bottom), //
            Vector2.init(block_left + self.notch_x_offset, block_bottom), //
            Vector2.init(block_left + self.notch_x_offset + (self.notch_width / 2), block_bottom + self.notch_depth), //
            Vector2.init(block_left + self.notch_x_offset + self.notch_width, block_bottom), //
            Vector2.init(block_right, block_bottom), //
        }, //
            2.0, Color.black);
        raylib.drawSplineLinear(&[_]Vector2{ //
            Vector2.init(block_left, block_top), //
            Vector2.init(block_left, block_bottom), //
            Vector2.init(block_left + self.notch_x_offset, block_bottom), //
            Vector2.init(block_left + self.notch_x_offset + (self.notch_width / 2), block_bottom + self.notch_depth), //
            Vector2.init(block_left + self.notch_x_offset + self.notch_width, block_bottom), //
            Vector2.init(block_right, block_bottom), //
            Vector2.init(block_right, block_top), //
        }, //
            2.0, Color.black);
    }

    fn draw(self: *Block, position: Vector2) void {
        self.position = position;

        switch (self.type) {
            .output => {
                self.draw_top_notch();
                self.draw_bottom_rect();
            },
            .input => {
                self.draw_top_rect();
                self.draw_bottom_notch();
            },
            .middle => {
                self.draw_top_notch();
                self.draw_bottom_notch();
            },
        }

        raylib.drawText(self.text, //
            @as(i32, @intFromFloat(self.position.x + PADDING)), //
            @as(i32, @intFromFloat(self.position.y +
            self.notch_depth + PADDING)), //
            FONT_SIZE, self.text_color);
    }
};

const BlockType = enum { output, input, middle };

const Mode = enum {
    Navigate,
    Picker,
};

const Keybinding = struct {
    key: [*:0]const u8,
    description: [*:0]const u8,
};

const Editor = struct {
    mode: Mode,
    blocks: std.ArrayList(Block),
    cursor: usize = 0,
    picker_cursor: usize = 0,
    picker_active: bool = false,
    available_blocks: *const [2]Block = &[_]Block{ Block.init_input(), Block.init(BlockType.middle) },
    show_help: bool = false,
    keybindings: []const Keybinding = &[_]Keybinding{ //
        Keybinding{
            .key = "?",
            .description = "Show help menu",
        },
        Keybinding{
            .key = "Escape",
            .description = "Change to Block Picking Mode",
        },
        Keybinding{
            .key = "i",
            .description = "Change to Edit Mode",
        },
        Keybinding{
            .key = "j",
            .description = "Down",
        },
        Keybinding{
            .key = "j",
            .description = "Up",
        },
        Keybinding{
            .key = "Escape",
            .description = "Exit help menu",
        },
    },

    fn init() Editor {
        var editor = Editor{ .mode = Mode.Navigate, .blocks = std.ArrayList(Block).init(GLOBAL_ALLOCATOR) };

        editor.blocks.append(Block.init(BlockType.input)) catch std.log.debug("fuck", .{});
        editor.blocks.append(Block.init(BlockType.output)) catch std.log.debug("fuck", .{});

        return editor;
    }

    fn deinit(self: *Editor) void {
        self.blocks.deinit();
    }

    fn respondToKey(self: *Editor) void {
        const key = raylib.getKeyPressed();

        if (key == KeyboardKey.key_i) {
            self.mode = Mode.Navigate;
        }

        if (key == KeyboardKey.key_escape) {
            if (self.show_help) {
                self.show_help = false;
            } else {
                self.mode = Mode.Picker;
            }
        }

        if (key == KeyboardKey.key_slash and
            (raylib.isKeyDown(KeyboardKey.key_left_shift) or
            raylib.isKeyDown(KeyboardKey.key_right_shift)))
        {
            self.show_help = true;
        }

        switch (self.mode) {
            Mode.Navigate => {
                const last_index = self.blocks.items.len - 1;
                // Doing my own array bounds check
                if (key == KeyboardKey.key_j) {
                    if (self.cursor < last_index) {
                        self.cursor += 1;
                    }
                }
                if (key == KeyboardKey.key_k) {
                    self.cursor -|= 1;
                }
                if (key == KeyboardKey.key_n) {
                    self.blocks.insert(self.cursor, Block.init(self.available_blocks[self.picker_cursor].type)) catch |err| {
                        std.debug.panic("shit {}", .{err});
                    };
                }
                if (key == KeyboardKey.key_d) {
                    const block = self.blocks.items[self.cursor];
                    if (block.type != BlockType.output) {
                        _ = self.blocks.orderedRemove(self.cursor);
                    }
                }
            },
            Mode.Picker => {
                const last_index = self.available_blocks.len - 1;
                // Doing my own array bounds check
                if (key == KeyboardKey.key_j) {
                    if (self.picker_cursor < last_index) {
                        self.picker_cursor += 1;
                    }
                }
                if (key == KeyboardKey.key_k) {
                    self.picker_cursor -|= 1;
                }
            },
        }
    }

    fn draw_navigation_cursor(self: *const Editor) void {
        var block = Block.init(BlockType.input);
        if (self.cursor > (self.blocks.items.len - 1)) {
            block = self.blocks.items[0];
        } else {
            block = self.blocks.items[self.cursor];
        }
        const cursor_color = Color.red;
        const thiccness = 2.0;

        raylib.drawLineEx( //
            Vector2.init(block.position.x + block.size.x, block.position.y), //
            Vector2.init(block.position.x + block.size.x + 50, block.position.y), //
            thiccness, //
            cursor_color //
        );
        raylib.drawSplineLinear( //
            &[_]Vector2{
            Vector2.init(block.position.x + block.size.x + 5, block.position.y + 5), //
            Vector2.init(block.position.x + block.size.x, block.position.y), //
            Vector2.init(block.position.x + block.size.x + 5, block.position.y - 5), //
        }, thiccness, //
            cursor_color //
        );
    }

    fn drawBar(self: *const Editor) void {
        const height = @as(f32, @floatFromInt(raylib.getScreenHeight()));
        const width = @as(f32, @floatFromInt(raylib.getScreenWidth()));

        const bar_thiccness = height - (height - (PADDING + FONT_SIZE));
        raylib.drawRectangleV(Vector2.init(0, height - bar_thiccness), Vector2.init(width, height), switch (self.mode) {
            .Navigate => Color.dark_green,
            .Picker => Color.dark_blue,
        });

        raylib.drawText(switch (self.mode) {
            .Navigate => "Edit Mode",
            .Picker => "Block Pick Mode",
        }, PADDING, @as(i32, @intFromFloat(height - (bar_thiccness - (PADDING / 2)))), FONT_SIZE, Color.white);
    }

    fn drawBlocks(self: *const Editor) void {
        for (self.blocks.items, 0..) |*block, index| {
            const pos = Vector2.init(PADDING, PADDING + @as(f32, @floatFromInt(index)) * block.size.y);
            block.draw(pos);
        }
    }

    fn drawAvailableBlocks(self: *const Editor) void {
        const width = @as(f32, @floatFromInt(raylib.getScreenWidth()));
        const block_width = @as(f32, @floatFromInt(raylib.measureText("Output", FONT_SIZE))) + (PADDING * 2);
        const block_height = FONT_SIZE + (PADDING * 2);

        var y_pos: f32 = PADDING;
        for (self.available_blocks) |block| {
            raylib.drawRectangleRec(Rectangle.init(width - block_width - (PADDING * 2), y_pos, block_width, block_height), block.color);
            raylib.drawText(block.text, @as(i32, @intFromFloat(width - block_width - PADDING)), @as(i32, @intFromFloat(y_pos + PADDING)), FONT_SIZE, block.text_color);
            y_pos += block_height;
        }
    }

    fn drawPickerMenu(self: *const Editor, picker_active: bool) void {
        const width = @as(f32, @floatFromInt(raylib.getScreenWidth()));
        const block_width = @as(f32, @floatFromInt(raylib.measureText("Output", FONT_SIZE))) + (PADDING * 2);
        const block_height = FONT_SIZE + (PADDING * 2);

        var y_pos: f32 = PADDING;
        y_pos += block_height * @as(f32, @floatFromInt(self.picker_cursor));

        raylib.drawRectangleLinesEx(Rectangle.init(width - block_width - (PADDING * 2), y_pos, block_width, block_height), 2.0, switch (picker_active) {
            true => Color.red,
            false => Color.dark_gray,
        });
    }

    fn showHelpMenu(self: *const Editor) void {
        const width = @as(f32, @floatFromInt(raylib.getScreenWidth()));
        const height = @as(f32, @floatFromInt(raylib.getScreenWidth()));

        raylib.drawRectangleRec(Rectangle.init(0, 0, width, height), BG_COLOR);
        var max_width: i32 = 0;
        for (self.keybindings) |keybind| {
            const text_width = raylib.measureText(keybind.key, FONT_SIZE);
            if (text_width > max_width) {
                max_width = text_width;
            }
        }
        for (self.keybindings, 0..) |keybind, i| {
            const idx = @as(i32, @intCast(i));
            const padding = @as(i32, @intFromFloat(PADDING));

            raylib.drawText(keybind.key, padding, padding + ((FONT_SIZE + padding) * idx), FONT_SIZE, Color.black);
            raylib.drawText(keybind.description, (padding * 2) + max_width, padding + (FONT_SIZE + padding) * idx, FONT_SIZE, Color.black);
        }
    }
};

pub fn main() !void {
    var editor = Editor.init();

    defer editor.blocks.deinit();

    raylib.setWindowState(.{
        .vsync_hint = true,
        .msaa_4x_hint = true,
        .window_highdpi = true,
    });

    raylib.initWindow(640, 480, "Viz");

    raylib.setExitKey(KeyboardKey.key_q);
    raylib.setWindowState(.{
        .window_resizable = false,
        // On Linux, a tiling window manager will allow you to resize anyway.
        // The only difference is that it will try to tile the window by default on Wayland.
    });

    defer raylib.closeWindow();
    while (!raylib.windowShouldClose()) {
        raylib.beginDrawing();

        raylib.clearBackground(BG_COLOR);

        editor.respondToKey();

        editor.drawBlocks();
        editor.drawAvailableBlocks();

        switch (editor.mode) {
            Mode.Navigate => {
                editor.picker_active = false;
                editor.draw_navigation_cursor();
            },
            Mode.Picker => editor.picker_active = true,
        }

        editor.drawPickerMenu(editor.picker_active);

        editor.drawBar();

        if (editor.show_help) {
            editor.showHelpMenu();
        }

        raylib.endDrawing();
    }
}
