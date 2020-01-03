const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const test_debug = b.addTest("test/des_test.zig");
    test_debug.addPackagePath("zig-crypto", "zig_crypto.zig");
    b.step("test_debug", "Run all tests in debug mode").dependOn(&test_debug.step);

    const test_release_fast = b.addTest("test/des_test.zig");
    test_release_fast.setBuildMode(.ReleaseFast);
    test_release_fast.addPackagePath("zig-crypto", "zig_crypto.zig");
    b.step("test_release_fast", "Run all tests in release-fast mode").dependOn(&test_release_fast.step);

    b.default_step.dependOn(&test_debug.step);
    b.default_step.dependOn(&test_release_fast.step);
}
