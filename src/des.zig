const std = @import("std");
const assert = @import("std").debug.assert;
const math = @import("std").math;
const mem = @import("std").mem;
const warn = @import("std").debug.warn;

// TODO: Figure out the endianness stuff, it's a total mess right now
// TODO: Figure out the endianness stuff, it's a total mess right now
// TODO: Figure out the endianness stuff, it's a total mess right now

// TODO: Use this instead of hardcoded 8 everywhere
pub const block_size: u8 = 8;

const ip = [64]u8{
    6, 14, 22, 30, 38, 46, 54, 62,
    4, 12, 20, 28, 36, 44, 52, 60,
    2, 10, 18, 26, 34, 42, 50, 58,
    0, 8, 16, 24, 32, 40, 48, 56,
    7, 15, 23, 31, 39, 47, 55, 63,
    5, 13, 21, 29, 37, 45, 53, 61,
    3, 11, 19, 27, 35, 43, 51, 59,
    1, 9, 17, 25, 33, 41, 49, 57,
};

const fp = [64]u8{
    24, 56, 16, 48, 8, 40, 0, 32,
    25, 57, 17, 49, 9, 41, 1, 33,
    26, 58, 18, 50, 10, 42, 2, 34,
    27, 59, 19, 51, 11, 43, 3, 35,
    28, 60, 20, 52, 12, 44, 4, 36,
    29, 61, 21, 53, 13, 45, 5, 37,
    30, 62, 22, 54, 14, 46, 6, 38,
    31, 63, 23, 55, 15, 47, 7, 39,
};

const pc1 = [56]u8{
    7, 15, 23, 31, 39, 47, 55, 63,
    6, 14, 22, 30, 38, 46, 54, 62,
    5, 13, 21, 29, 37, 45, 53, 61,
    4, 12, 20, 28, 1, 9, 17, 25,
    33, 41, 49, 57, 2, 10, 18, 26,
    34, 42, 50, 58, 3, 11, 19, 27,
    35, 43, 51, 59, 36, 44, 52, 60,
};

const pc2 = [48]u8{
    13, 16, 10, 23, 0, 4, 2, 27,
    14, 5, 20, 9, 22, 18, 11, 3,
    25, 7, 15, 6, 26, 19, 12, 1,
    40, 51, 30, 36, 46, 54, 29, 39,
    50, 44, 32, 47, 43, 48, 38, 55,
    33, 52, 45, 41, 49, 35, 28, 31,
};

const s0 = [_]u32{
    0x00410100, 0x00010000, 0x40400000, 0x40410100, 0x00400000, 0x40010100, 0x40010000, 0x40400000,
    0x40010100, 0x00410100, 0x00410000, 0x40000100, 0x40400100, 0x00400000, 0x00000000, 0x40010000,
    0x00010000, 0x40000000, 0x00400100, 0x00010100, 0x40410100, 0x00410000, 0x40000100, 0x00400100,
    0x40000000, 0x00000100, 0x00010100, 0x40410000, 0x00000100, 0x40400100, 0x40410000, 0x00000000,
    0x00000000, 0x40410100, 0x00400100, 0x40010000, 0x00410100, 0x00010000, 0x40000100, 0x00400100,
    0x40410000, 0x00000100, 0x00010100, 0x40400000, 0x40010100, 0x40000000, 0x40400000, 0x00410000,
    0x40410100, 0x00010100, 0x00410000, 0x40400100, 0x00400000, 0x40000100, 0x40010000, 0x00000000,
    0x00010000, 0x00400000, 0x40400100, 0x00410100, 0x40000000, 0x40410000, 0x00000100, 0x40010100,
};

const s1 = [_]u32{
    0x08021002, 0x00000000, 0x00021000, 0x08020000, 0x08000002, 0x00001002, 0x08001000, 0x00021000,
    0x00001000, 0x08020002, 0x00000002, 0x08001000, 0x00020002, 0x08021000, 0x08020000, 0x00000002,
    0x00020000, 0x08001002, 0x08020002, 0x00001000, 0x00021002, 0x08000000, 0x00000000, 0x00020002,
    0x08001002, 0x00021002, 0x08021000, 0x08000002, 0x08000000, 0x00020000, 0x00001002, 0x08021002,
    0x00020002, 0x08021000, 0x08001000, 0x00021002, 0x08021002, 0x00020002, 0x08000002, 0x00000000,
    0x08000000, 0x00001002, 0x00020000, 0x08020002, 0x00001000, 0x08000000, 0x00021002, 0x08001002,
    0x08021000, 0x00001000, 0x00000000, 0x08000002, 0x00000002, 0x08021002, 0x00021000, 0x08020000,
    0x08020002, 0x00020000, 0x00001002, 0x08001000, 0x08001002, 0x00000002, 0x08020000, 0x00021000,
};

const s2 = [_]u32{
    0x20800000, 0x00808020, 0x00000020, 0x20800020, 0x20008000, 0x00800000, 0x20800020, 0x00008020,
    0x00800020, 0x00008000, 0x00808000, 0x20000000, 0x20808020, 0x20000020, 0x20000000, 0x20808000,
    0x00000000, 0x20008000, 0x00808020, 0x00000020, 0x20000020, 0x20808020, 0x00008000, 0x20800000,
    0x20808000, 0x00800020, 0x20008020, 0x00808000, 0x00008020, 0x00000000, 0x00800000, 0x20008020,
    0x00808020, 0x00000020, 0x20000000, 0x00008000, 0x20000020, 0x20008000, 0x00808000, 0x20800020,
    0x00000000, 0x00808020, 0x00008020, 0x20808000, 0x20008000, 0x00800000, 0x20808020, 0x20000000,
    0x20008020, 0x20800000, 0x00800000, 0x20808020, 0x00008000, 0x00800020, 0x20800020, 0x00008020,
    0x00800020, 0x00000000, 0x20808000, 0x20000020, 0x20800000, 0x20008020, 0x00000020, 0x00808000,
};

const s3 = [_]u32{
    0x00080201, 0x02000200, 0x00000001, 0x02080201, 0x00000000, 0x02080000, 0x02000201, 0x00080001,
    0x02080200, 0x02000001, 0x02000000, 0x00000201, 0x02000001, 0x00080201, 0x00080000, 0x02000000,
    0x02080001, 0x00080200, 0x00000200, 0x00000001, 0x00080200, 0x02000201, 0x02080000, 0x00000200,
    0x00000201, 0x00000000, 0x00080001, 0x02080200, 0x02000200, 0x02080001, 0x02080201, 0x00080000,
    0x02080001, 0x00000201, 0x00080000, 0x02000001, 0x00080200, 0x02000200, 0x00000001, 0x02080000,
    0x02000201, 0x00000000, 0x00000200, 0x00080001, 0x00000000, 0x02080001, 0x02080200, 0x00000200,
    0x02000000, 0x02080201, 0x00080201, 0x00080000, 0x02080201, 0x00000001, 0x02000200, 0x00080201,
    0x00080001, 0x00080200, 0x02080000, 0x02000201, 0x00000201, 0x02000000, 0x02000001, 0x02080200,
};

const s4 = [_]u32{
    0x01000000, 0x00002000, 0x00000080, 0x01002084, 0x01002004, 0x01000080, 0x00002084, 0x01002000,
    0x00002000, 0x00000004, 0x01000004, 0x00002080, 0x01000084, 0x01002004, 0x01002080, 0x00000000,
    0x00002080, 0x01000000, 0x00002004, 0x00000084, 0x01000080, 0x00002084, 0x00000000, 0x01000004,
    0x00000004, 0x01000084, 0x01002084, 0x00002004, 0x01002000, 0x00000080, 0x00000084, 0x01002080,
    0x01002080, 0x01000084, 0x00002004, 0x01002000, 0x00002000, 0x00000004, 0x01000004, 0x01000080,
    0x01000000, 0x00002080, 0x01002084, 0x00000000, 0x00002084, 0x01000000, 0x00000080, 0x00002004,
    0x01000084, 0x00000080, 0x00000000, 0x01002084, 0x01002004, 0x01002080, 0x00000084, 0x00002000,
    0x00002080, 0x01002004, 0x01000080, 0x00000084, 0x00000004, 0x00002084, 0x01002000, 0x01000004,
};

const s5 = [_]u32{
    0x10000008, 0x00040008, 0x00000000, 0x10040400, 0x00040008, 0x00000400, 0x10000408, 0x00040000,
    0x00000408, 0x10040408, 0x00040400, 0x10000000, 0x10000400, 0x10000008, 0x10040000, 0x00040408,
    0x00040000, 0x10000408, 0x10040008, 0x00000000, 0x00000400, 0x00000008, 0x10040400, 0x10040008,
    0x10040408, 0x10040000, 0x10000000, 0x00000408, 0x00000008, 0x00040400, 0x00040408, 0x10000400,
    0x00000408, 0x10000000, 0x10000400, 0x00040408, 0x10040400, 0x00040008, 0x00000000, 0x10000400,
    0x10000000, 0x00000400, 0x10040008, 0x00040000, 0x00040008, 0x10040408, 0x00040400, 0x00000008,
    0x10040408, 0x00040400, 0x00040000, 0x10000408, 0x10000008, 0x10040000, 0x00040408, 0x00000000,
    0x00000400, 0x10000008, 0x10000408, 0x10040400, 0x10040000, 0x00000408, 0x00000008, 0x10040008,
};

const s6 = [_]u32{
    0x00000800, 0x00000040, 0x00200040, 0x80200000, 0x80200840, 0x80000800, 0x00000840, 0x00000000,
    0x00200000, 0x80200040, 0x80000040, 0x00200800, 0x80000000, 0x00200840, 0x00200800, 0x80000040,
    0x80200040, 0x00000800, 0x80000800, 0x80200840, 0x00000000, 0x00200040, 0x80200000, 0x00000840,
    0x80200800, 0x80000840, 0x00200840, 0x80000000, 0x80000840, 0x80200800, 0x00000040, 0x00200000,
    0x80000840, 0x00200800, 0x80200800, 0x80000040, 0x00000800, 0x00000040, 0x00200000, 0x80200800,
    0x80200040, 0x80000840, 0x00000840, 0x00000000, 0x00000040, 0x80200000, 0x80000000, 0x00200040,
    0x00000000, 0x80200040, 0x00200040, 0x00000840, 0x80000040, 0x00000800, 0x80200840, 0x00200000,
    0x00200840, 0x80000000, 0x80000800, 0x80200840, 0x80200000, 0x00200840, 0x00200800, 0x80000800,
};

const s7 = [_]u32{
    0x04100010, 0x04104000, 0x00004010, 0x00000000, 0x04004000, 0x00100010, 0x04100000, 0x04104010,
    0x00000010, 0x04000000, 0x00104000, 0x00004010, 0x00104010, 0x04004010, 0x04000010, 0x04100000,
    0x00004000, 0x00104010, 0x00100010, 0x04004000, 0x04104010, 0x04000010, 0x00000000, 0x00104000,
    0x04000000, 0x00100000, 0x04004010, 0x04100010, 0x00100000, 0x00004000, 0x04104000, 0x00000010,
    0x00100000, 0x00004000, 0x04000010, 0x04104010, 0x00004010, 0x04000000, 0x00000000, 0x00104000,
    0x04100010, 0x04004010, 0x04004000, 0x00100010, 0x04104000, 0x00000010, 0x00100010, 0x04004000,
    0x04104010, 0x00100000, 0x04100000, 0x04000010, 0x00104000, 0x00004010, 0x04004010, 0x04100000,
    0x00000010, 0x04104000, 0x00104010, 0x00000000, 0x04000000, 0x04100010, 0x00004000, 0x00104010,
};

const sboxes = [8][64]u32{ s0, s1, s2, s3, s4, s5, s6, s7 };

fn expand(half: u32) u48 {
    const mask: u8 = (1 << 6) - 1;

    var i: u5 = 0;
    var out: u48 = std.math.rotl(u32, half, 1) & mask;
    while (i < 7) : (i += 1) {
        const piece: u48 = (half >> (3 + (4 * i))) & mask;
        out ^= @truncate(u48, piece << 6 * @intCast(u6, i + 1));
    }
    out ^= (@intCast(u48, half) & 1) << 47;
    return out;
}


// Bugged in --release-fast with this type signature, see https://github.com/ziglang/zig/issues/3980
// fn permuteBits(long: var, indices: []const math.Log2Int(@TypeOf(long))) @TypeOf(long) {
fn permuteBits(long: var, indices: []const u8) @TypeOf(long) {
    comptime const T = @TypeOf(long);
    comptime const TL = math.Log2Int(T);

    var out: T = 0;
    for (indices) |x, i| {
        out ^= (((long >> @intCast(u6, x)) & 1) << @intCast(TL, i));
    }
    return out;
}

const shifts = [_]u5{
    1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1,
};

fn sbox(long: u48) u32 {
    var out: u32 = 0;
    for (sboxes) |*box, i| {
        const shift: u6 = @intCast(u6, i * 6);
        out ^= box.*[@truncate(u6, (long >> shift) & 0b111111)];
    }
    return out;
}

pub fn desRounds(keys: []const u48, data: u64, comptime encrypt: bool) [8]u8 {
    var perm = permuteBits(data, ip[0..]);

    var i: u8 = 0;
    var left = @truncate(u32, perm & 0xFFFFFFFF);
    var right = @truncate(u32, perm >> 32);
    var work: u48 = 0;
    var swork: u32 = 0;

    while (i < 16) : (i += 1) {
        work = expand(right) ^ keys[if (encrypt) i else (15 - i)];
        swork = sbox(work);

        const oldRight = right;
        right = left ^ swork;
        left = oldRight;
    }

    var out: u64 = left;
    out <<= 32;
    out ^= right;
    out = permuteBits(out, fp[0..]);

    return mem.asBytes(&out).*;
}

pub fn subkeys(keyBytes: []const u8) [16]u48 {
    const size: u6 = math.maxInt(u6);
    const key = mem.readIntSliceBig(u64, keyBytes[0..]);
    var perm = @truncate(u56, permuteBits(key, pc1[0..]));

    var left: u28 = @truncate(u28, perm & 0xfffffff);
    var right: u28 = @truncate(u28, (perm >> 28) & 0xfffffff);
    var subkey: u48 = 0;
    var i: u8 = 0;
    var keys: [16]u48 = undefined;

    while (i < 16) : (i += 1) {
        left = std.math.rotr(u28, left, shifts[i]);
        right = std.math.rotr(u28, right, shifts[i]);

        var out: u56 = right;
        out <<= 28;
        out ^= left;

        subkey = @truncate(u48, permuteBits(out, pc2[0..]));
        keys[i] = subkey;
    }

    return keys;
}

// TODO: Clean up all these functions and make a consistent API

pub fn desEncryptCbc(key: []const u8, iv: []const u8, inData: []const u8, outData: []u8) void {
    assert(key.len == 8);
    assert(iv.len == 8);
    assert(inData.len % 8 == 0);

    var i: u64 = 0;
    var offset: u64 = 0;
    const keys = subkeys(key);
    var block: u64 = mem.readIntSliceBig(u64, iv);
    while (offset <= inData.len - 8) {
        const plain: u64 = mem.readIntSliceBig(u64, inData[offset..(offset + 8)]);
        const cipher = desRounds(keys[0..], plain ^ block, true);
        for (cipher) |c, j| {
            outData[(i * 8) + (7 - j)] = c;
        }
        block = mem.readIntSliceLittle(u64, cipher[0..]);
        i += 1;
        offset += 8;
    }
}

pub fn desDecryptCbc(key: []const u8, iv: []const u8, inData: []const u8, outData: []u8) void {
    assert(key.len == 8);
    assert(iv.len == 8);
    assert(inData.len % 8 == 0);

    var i: u64 = 0;
    var offset: u64 = 0;
    const keys = subkeys(key);
    var block = iv;
    while (offset <= inData.len - 8) {
        const cipher = inData[offset..(offset + 8)];
        const cipher64: u64 = mem.readIntSliceBig(u64, cipher);
        const plain = desRounds(keys[0..], cipher64, false);
        for (plain) |p, j| {
            outData[(i * 8) + (7 - j)] = p ^ block[7 - j];
        }
        block = cipher;
        i += 1;
        offset += 8;
    }
}

pub fn des3EncryptCbc(key: []const u8, iv: []const u8, inData: []const u8, outData: []u8) void {
    assert(key.len == 24);
    assert(iv.len == 8);
    assert(inData.len % 8 == 0);


    var i: u64 = 0;
    var offset: u64 = 0;
    var buf = [_]u8{0} ** 8;
    var out = [_]u8{0} ** 8;
    var block = [_]u8{0} ** 8;
    mem.copy(u8, block[0..], iv[0..]);
    while (offset <= inData.len - 8) {
        mem.copy(u8, buf[0..], inData[offset..(offset + 8)]);
        for (buf) |*p, j| {
            p.* ^= block[j];
        }
        des3EncryptEcb(key, buf[0..], out[0..]);
        for (out) |c, j| {
            outData[(i * 8) + j] = c;
        }
        mem.copy(u8, block[0..], out[0..]);
        i += 1;
        offset += 8;
    }
}

pub fn des3DecryptCbc(key: []const u8, iv: []const u8, inData: []const u8, outData: []u8) void {
    assert(key.len == 24);
    assert(iv.len == 8);
    assert(inData.len % 8 == 0);


    var i: u64 = 0;
    var offset: u64 = 0;
    var buf = [_]u8{0} ** 8;
    var out = [_]u8{0} ** 8;
    var block = [_]u8{0} ** 8;
    mem.copy(u8, block[0..], iv[0..]);
    while (offset <= inData.len - 8) {
        mem.copy(u8, buf[0..], inData[offset..(offset + 8)]);
        // TODO: Pass in the subkeys instead of the key bytes here
        des3DecryptEcb(key, buf[0..], out[0..]);
        for (out) |*p, j| {
            p.* ^= block[j];
        }
        for (out) |c, j| {
            outData[(i * 8) + j] = c;
        }
        mem.copy(u8, block[0..], buf[0..]);
        i += 1;
        offset += 8;
    }
}

pub fn desEncryptEcb(keyBytes: []const u8, inData: []const u8, outData: []u8) void {
    assert(keyBytes.len == 8);
    assert(inData.len % 8 == 0);

    var i: u64 = 0;
    var offset: u64 = 0;
    const keys = subkeys(keyBytes);
    while (offset <= inData.len - 8) {
        const plain: u64 = mem.readIntSliceBig(u64, inData[offset..(offset + 8)]);
        const cipher = desRounds(keys[0..], plain, true);
        for (cipher) |c, j| {
            outData[(i * 8) + (7 - j)] = c;
        }
        i += 1;
        offset += 8;
    }
}

pub fn desDecryptEcb(keyBytes: []const u8, inData: []const u8, outData: []u8) void {
    assert(keyBytes.len == 8);
    assert(inData.len % 8 == 0);

    var i: u64 = 0;
    var offset: u64 = 0;
    const keys = subkeys(keyBytes);
    while (offset <= inData.len - 8) {
        const cipher: u64 = mem.readIntSliceBig(u64, inData[offset..(offset + 8)]);
        const plain = desRounds(keys[0..], cipher, false);
        for (plain) |p, j| {
            outData[(i * 8) + (7 - j)] = p;
        }
        i += 1;
        offset += 8;
    }
}

pub fn des3EncryptEcb(keyBytes: []const u8, inData: []const u8, outData: []u8) void {
    assert(keyBytes.len == 24);
    assert(inData.len % 8 == 0);

    var i: u64 = 0;
    var offset: u64 = 0;
    const keys1 = subkeys(keyBytes[0..8]);
    const keys2 = subkeys(keyBytes[8..16]);
    const keys3 = subkeys(keyBytes[16..]);
    while (offset <= inData.len - 8) {
        const plain: u64 = mem.readIntSliceBig(u64, inData[offset..(offset + 8)]);
        var cipher = desRounds(keys1[0..], plain, true);
        cipher = desRounds(keys2[0..], mem.readIntSliceLittle(u64, cipher[0..]), false);
        cipher = desRounds(keys3[0..], mem.readIntSliceLittle(u64, cipher[0..]), true);
        for (cipher) |c, j| {
            outData[(i * 8) + (7 - j)] = c;
        }
        i += 1;
        offset += 8;
    }
}

pub fn des3DecryptEcb(keyBytes: []const u8, inData: []const u8, outData: []u8) void {
    assert(keyBytes.len == 24);
    assert(inData.len % 8 == 0);

    var i: u64 = 0;
    var offset: u64 = 0;
    const keys1 = subkeys(keyBytes[0..8]);
    const keys2 = subkeys(keyBytes[8..16]);
    const keys3 = subkeys(keyBytes[16..]);
    while (offset <= inData.len - 8) {
        const plain: u64 = mem.readIntSliceBig(u64, inData[offset..(offset + 8)]);
        var cipher = desRounds(keys3[0..], plain, false);
        cipher = desRounds(keys2[0..], mem.readIntSliceLittle(u64, cipher[0..]), true);
        cipher = desRounds(keys1[0..], mem.readIntSliceLittle(u64, cipher[0..]), false);
        for (cipher) |c, j| {
            outData[(i * 8) + (7 - j)] = c;
        }
        i += 1;
        offset += 8;
    }
}
