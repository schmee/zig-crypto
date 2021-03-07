const assert = @import("std").debug.assert;
const builtin = @import("std").builtin;
const math = @import("std").math;
const mem = @import("std").mem;

pub const block_size: u8 = 8;

const ip = [64]u8{
    6, 14, 22, 30, 38, 46, 54, 62,
    4, 12, 20, 28, 36, 44, 52, 60,
    2, 10, 18, 26, 34, 42, 50, 58,
    0, 8,  16, 24, 32, 40, 48, 56,
    7, 15, 23, 31, 39, 47, 55, 63,
    5, 13, 21, 29, 37, 45, 53, 61,
    3, 11, 19, 27, 35, 43, 51, 59,
    1, 9,  17, 25, 33, 41, 49, 57,
};

const fp = [64]u8{
    31, 63, 23, 55, 15, 47, 7, 39,
    30, 62, 22, 54, 14, 46, 6, 38,
    29, 61, 21, 53, 13, 45, 5, 37,
    28, 60, 20, 52, 12, 44, 4, 36,
    27, 59, 19, 51, 11, 43, 3, 35,
    26, 58, 18, 50, 10, 42, 2, 34,
    25, 57, 17, 49, 9,  41, 1, 33,
    24, 56, 16, 48, 8,  40, 0, 32,
};

const pc1 = [56]u8{
    7,  15, 23, 31, 39, 47, 55, 63,
    6,  14, 22, 30, 38, 46, 54, 62,
    5,  13, 21, 29, 37, 45, 53, 61,
    4,  12, 20, 28, 1,  9,  17, 25,
    33, 41, 49, 57, 2,  10, 18, 26,
    34, 42, 50, 58, 3,  11, 19, 27,
    35, 43, 51, 59, 36, 44, 52, 60,
};

const pc2 = [48]u8{
    13, 16, 10, 23, 0,  4,  2,  27,
    14, 5,  20, 9,  22, 18, 11, 3,
    25, 7,  15, 6,  26, 19, 12, 1,
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

pub const CryptMode = enum {
    Encrypt,
    Decrypt
};

fn permuteBits(long: anytype, indices: []const u8) @TypeOf(long) {
    comptime const T = @TypeOf(long);
    comptime const TL = math.Log2Int(T);

    var out: T = 0;
    for (indices) |x, i| {
        out ^= (((long >> @intCast(u6, x)) & 1) << @intCast(TL, i));
    }
    return out;
}

fn precomutePermutation(comptime permutation: []const u8) [8][256]u64 {
    @setEvalBranchQuota(1000000);
    comptime var i: u64 = 0;
    comptime var out: [8][256]u64 = undefined;
    inline while (i < 8) : (i += 1) {
        comptime var j: u64 = 0;
        inline while (j < 256) : (j += 1) {
            var p: u64 = j << (i * 8);
            out[i][j] = permuteBits(p, permutation);
        }
    }
    return out;
}

fn permuteBitsPrecomputed(long: u64, comptime precomputedPerm: [8][256]u64) u64 {
    var out: u64 = 0;
    inline for (precomputedPerm) |p, i| {
        out ^= p[@truncate(u8, long >> @intCast(u6, i * 8))];
    }
    return out;
}

fn initialPermutation(long: u64) u64 {
    return if (builtin.mode == .ReleaseSmall)
        permuteBits(long, &ip)
    else
        permuteBitsPrecomputed(long, comptime precomutePermutation(&ip));
}

fn finalPermutation(long: u64) u64 {
    return if (builtin.mode == .ReleaseSmall)
        permuteBits(long, &fp)
    else
        permuteBitsPrecomputed(long, comptime precomutePermutation(&fp));
}

fn permutePc1(long: u64) u64 {
    if (builtin.mode == .ReleaseSmall) {
        return permuteBits(long, &pc1);
    } else {
        comptime const prepc1 = precomutePermutation(&pc1);
        return permuteBitsPrecomputed(long, prepc1);
    }
}

fn permutePc2(long: u56) u56 {
    if (builtin.mode == .ReleaseSmall) {
        return permuteBits(long, &pc2);
    } else {
        comptime const prepc2 = precomutePermutation(&pc2);
        return @intCast(u56, permuteBitsPrecomputed(@as(u64, long), prepc2));
    }
}

pub fn cryptBlock(comptime crypt_mode: CryptMode, keys: []const u48, dest: []u8, source: []const u8) void {
    assert(source.len == block_size);
    assert(dest.len >= block_size);

    const dataLong = mem.readIntSliceBig(u64, source);
    const perm = initialPermutation(dataLong);

    var left = @truncate(u32, perm & 0xFFFFFFFF);
    var right = @truncate(u32, perm >> 32);

    comptime var i: u8 = 0;
    inline while (i < 16) : (i += 1) {
        const r = right;
        const k = keys[if (crypt_mode == .Encrypt) i else (15 - i)];
        var work: u32 = 0;

        work = s0[@truncate(u6, math.rotl(u32, r, 1)) ^ @truncate(u6, k)]
             ^ s1[@truncate(u6, r >> 3) ^ @truncate(u6, k >> 6)]
             ^ s2[@truncate(u6, r >> 7) ^ @truncate(u6, k >> 12)]
             ^ s3[@truncate(u6, r >> 11) ^ @truncate(u6, k >> 18)]
             ^ s4[@truncate(u6, r >> 15) ^ @truncate(u6, k >> 24)]
             ^ s5[@truncate(u6, r >> 19) ^ @truncate(u6, k >> 30)]
             ^ s6[@truncate(u6, r >> 23) ^ @truncate(u6, k >> 36)]
             ^ s7[@truncate(u6, math.rotr(u32, r, 1) >> 26) ^ @truncate(u6, k >> 42)];

        right = left ^ work;
        left = r;
    }

    var out: u64 = left;
    out <<= 32;
    out ^= right;
    out = finalPermutation(out);
    const outBytes = mem.asBytes(&out);
    mem.copy(u8, dest, outBytes);
}

const shifts = [_]u32{
    1, 2, 4, 6, 8, 10, 12, 14, 15, 17, 19, 21, 23, 25, 27, 28
};

pub fn subkeys(keyBytes: []const u8) [16]u48 {
    assert(keyBytes.len == block_size);

    const size: u6 = math.maxInt(u6);
    const key = mem.readIntSliceBig(u64, keyBytes);
    const perm = @truncate(u56, permutePc1(key));

    var left: u28 = @truncate(u28, perm & 0xfffffff);
    var right: u28 = @truncate(u28, (perm >> 28) & 0xfffffff);
    var keys: [16]u48 = undefined;

    inline for (shifts) |shift, i| {
        var subkey: u56 = math.rotr(u28, right, shift);
        subkey <<= 28;
        subkey ^= math.rotr(u28, left, shift);
        subkey = permutePc2(subkey);
        keys[i] = @truncate(u48, subkey);
    }

    return keys;
}

pub const DES = struct {
    const Self = @This();

    subkeys: [16]u48,

    pub fn init(key: [8]u8) Self {
        return Self {
            .subkeys = subkeys(&key)
        };
    }

    pub fn crypt(self: Self, crypt_mode: CryptMode, dest: []u8, source: []const u8) void {
        return switch (crypt_mode) {
            .Encrypt => cryptBlock(.Encrypt, &self.subkeys, dest, source),
            .Decrypt => cryptBlock(.Decrypt, &self.subkeys, dest, source),
        };
    }
};

pub const TDES = struct {
    const Self = @This();

    subkeys: [3][16]u48,

    pub fn init(key: [24]u8) Self {
        return Self {
            .subkeys = [_][16]u48{
                subkeys(key[0..8]),
                subkeys(key[8..16]),
                subkeys(key[16..])
            }
        };
    }

    pub fn crypt(self: Self, crypt_mode: CryptMode, dest: []u8, source: []const u8) void {
        var work: [8]u8 = undefined;
        mem.copy(u8, &work, source);
        switch (crypt_mode) {
            .Encrypt => {
                cryptBlock(.Encrypt, &self.subkeys[0], &work, &work);
                cryptBlock(.Decrypt, &self.subkeys[1], &work, &work);
                cryptBlock(.Encrypt, &self.subkeys[2], &work, &work);
            },
            .Decrypt => {
                cryptBlock(.Decrypt, &self.subkeys[2], &work, &work);
                cryptBlock(.Encrypt, &self.subkeys[1], &work, &work);
                cryptBlock(.Decrypt, &self.subkeys[0], &work, &work);
            }
        }
        mem.copy(u8, dest, &work);
    }
};
