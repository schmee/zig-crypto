const std = @import("std");
const Sha1 = std.crypto.Sha1;
const expectEqual = std.testing.expectEqual;
const fmt = std.fmt;
const mem = std.mem;
const os = std.os;
const testing = std.testing;

const des = @import("zig-crypto").des;
const DES = des.DES;
const TDES = des.TDES;

fn desRoundsInt(comptime crypt_mode: des.CryptMode, keyLong: u64, dataLong: u64) u64 {
    const reversedKey = @byteSwap(u64, keyLong);
    const key = mem.asBytes(&reversedKey).*;
    const reversedData = @byteSwap(u64, dataLong);
    const source = mem.asBytes(&reversedData);

    var dest: [8]u8 = undefined;
    var cipher = DES.init(key);
    cipher.crypt(crypt_mode, &dest, source);
    return mem.readIntBig(u64, &dest);
}

fn desEncryptTest(keyLong: u64, dataLong: u64) u64 {
    return desRoundsInt(.Encrypt, keyLong, dataLong);
}

fn desDecryptTest(keyLong: u64, dataLong: u64) u64 {
    return desRoundsInt(.Decrypt, keyLong, dataLong);
}

// https://www.cosic.esat.kuleuven.be/nessie/testvectors/bc/des/Des-64-64.test-vectors
test "DES encrypt" {
    expectEqual(@as(u64, 0x994D4DC157B96C52), desEncryptTest(0x0101010101010101, 0x0101010101010101));
    expectEqual(@as(u64, 0xE127C2B61D98E6E2), desEncryptTest(0x0202020202020202, 0x0202020202020202));
    expectEqual(@as(u64, 0x984C91D78A269CE3), desEncryptTest(0x0303030303030303, 0x0303030303030303));
    expectEqual(@as(u64, 0x1F4570BB77550683), desEncryptTest(0x0404040404040404, 0x0404040404040404));
    expectEqual(@as(u64, 0x3990ABF98D672B16), desEncryptTest(0x0505050505050505, 0x0505050505050505));
    expectEqual(@as(u64, 0x3F5150BBA081D585), desEncryptTest(0x0606060606060606, 0x0606060606060606));
    expectEqual(@as(u64, 0xC65242248C9CF6F2), desEncryptTest(0x0707070707070707, 0x0707070707070707));
    expectEqual(@as(u64, 0x10772D40FAD24257), desEncryptTest(0x0808080808080808, 0x0808080808080808));
    expectEqual(@as(u64, 0xF0139440647A6E7B), desEncryptTest(0x0909090909090909, 0x0909090909090909));
    expectEqual(@as(u64, 0x0A288603044D740C), desEncryptTest(0x0A0A0A0A0A0A0A0A, 0x0A0A0A0A0A0A0A0A));
    expectEqual(@as(u64, 0x6359916942F7438F), desEncryptTest(0x0B0B0B0B0B0B0B0B, 0x0B0B0B0B0B0B0B0B));
    expectEqual(@as(u64, 0x934316AE443CF08B), desEncryptTest(0x0C0C0C0C0C0C0C0C, 0x0C0C0C0C0C0C0C0C));
    expectEqual(@as(u64, 0xE3F56D7F1130A2B7), desEncryptTest(0x0D0D0D0D0D0D0D0D, 0x0D0D0D0D0D0D0D0D));
    expectEqual(@as(u64, 0xA2E4705087C6B6B4), desEncryptTest(0x0E0E0E0E0E0E0E0E, 0x0E0E0E0E0E0E0E0E));
    expectEqual(@as(u64, 0xD5D76E09A447E8C3), desEncryptTest(0x0F0F0F0F0F0F0F0F, 0x0F0F0F0F0F0F0F0F));
    expectEqual(@as(u64, 0xDD7515F2BFC17F85), desEncryptTest(0x1010101010101010, 0x1010101010101010));
    expectEqual(@as(u64, 0xF40379AB9E0EC533), desEncryptTest(0x1111111111111111, 0x1111111111111111));
    expectEqual(@as(u64, 0x96CD27784D1563E5), desEncryptTest(0x1212121212121212, 0x1212121212121212));
    expectEqual(@as(u64, 0x2911CF5E94D33FE1), desEncryptTest(0x1313131313131313, 0x1313131313131313));
    expectEqual(@as(u64, 0x377B7F7CA3E5BBB3), desEncryptTest(0x1414141414141414, 0x1414141414141414));
    expectEqual(@as(u64, 0x701AA63832905A92), desEncryptTest(0x1515151515151515, 0x1515151515151515));
    expectEqual(@as(u64, 0x2006E716C4252D6D), desEncryptTest(0x1616161616161616, 0x1616161616161616));
    expectEqual(@as(u64, 0x452C1197422469F8), desEncryptTest(0x1717171717171717, 0x1717171717171717));
    expectEqual(@as(u64, 0xC33FD1EB49CB64DA), desEncryptTest(0x1818181818181818, 0x1818181818181818));
    expectEqual(@as(u64, 0x7572278F364EB50D), desEncryptTest(0x1919191919191919, 0x1919191919191919));
    expectEqual(@as(u64, 0x69E51488403EF4C3), desEncryptTest(0x1A1A1A1A1A1A1A1A, 0x1A1A1A1A1A1A1A1A));
    expectEqual(@as(u64, 0xFF847E0ADF192825), desEncryptTest(0x1B1B1B1B1B1B1B1B, 0x1B1B1B1B1B1B1B1B));
    expectEqual(@as(u64, 0x521B7FB3B41BB791), desEncryptTest(0x1C1C1C1C1C1C1C1C, 0x1C1C1C1C1C1C1C1C));
    expectEqual(@as(u64, 0x26059A6A0F3F6B35), desEncryptTest(0x1D1D1D1D1D1D1D1D, 0x1D1D1D1D1D1D1D1D));
    expectEqual(@as(u64, 0xF24A8D2231C77538), desEncryptTest(0x1E1E1E1E1E1E1E1E, 0x1E1E1E1E1E1E1E1E));
    expectEqual(@as(u64, 0x4FD96EC0D3304EF6), desEncryptTest(0x1F1F1F1F1F1F1F1F, 0x1F1F1F1F1F1F1F1F));
}

test "DES decrypt" {
    expectEqual(@as(u64, 0x0101010101010101), desDecryptTest(0x0101010101010101, 0x994D4DC157B96C52));
    expectEqual(@as(u64, 0x0202020202020202), desDecryptTest(0x0202020202020202, 0xE127C2B61D98E6E2));
    expectEqual(@as(u64, 0x0303030303030303), desDecryptTest(0x0303030303030303, 0x984C91D78A269CE3));
    expectEqual(@as(u64, 0x0404040404040404), desDecryptTest(0x0404040404040404, 0x1F4570BB77550683));
    expectEqual(@as(u64, 0x0505050505050505), desDecryptTest(0x0505050505050505, 0x3990ABF98D672B16));
    expectEqual(@as(u64, 0x0606060606060606), desDecryptTest(0x0606060606060606, 0x3F5150BBA081D585));
    expectEqual(@as(u64, 0x0707070707070707), desDecryptTest(0x0707070707070707, 0xC65242248C9CF6F2));
    expectEqual(@as(u64, 0x0808080808080808), desDecryptTest(0x0808080808080808, 0x10772D40FAD24257));
    expectEqual(@as(u64, 0x0909090909090909), desDecryptTest(0x0909090909090909, 0xF0139440647A6E7B));
    expectEqual(@as(u64, 0x0A0A0A0A0A0A0A0A), desDecryptTest(0x0A0A0A0A0A0A0A0A, 0x0A288603044D740C));
    expectEqual(@as(u64, 0x0B0B0B0B0B0B0B0B), desDecryptTest(0x0B0B0B0B0B0B0B0B, 0x6359916942F7438F));
    expectEqual(@as(u64, 0x0C0C0C0C0C0C0C0C), desDecryptTest(0x0C0C0C0C0C0C0C0C, 0x934316AE443CF08B));
    expectEqual(@as(u64, 0x0D0D0D0D0D0D0D0D), desDecryptTest(0x0D0D0D0D0D0D0D0D, 0xE3F56D7F1130A2B7));
    expectEqual(@as(u64, 0x0E0E0E0E0E0E0E0E), desDecryptTest(0x0E0E0E0E0E0E0E0E, 0xA2E4705087C6B6B4));
    expectEqual(@as(u64, 0x0F0F0F0F0F0F0F0F), desDecryptTest(0x0F0F0F0F0F0F0F0F, 0xD5D76E09A447E8C3));
    expectEqual(@as(u64, 0x1010101010101010), desDecryptTest(0x1010101010101010, 0xDD7515F2BFC17F85));
    expectEqual(@as(u64, 0x1111111111111111), desDecryptTest(0x1111111111111111, 0xF40379AB9E0EC533));
    expectEqual(@as(u64, 0x1212121212121212), desDecryptTest(0x1212121212121212, 0x96CD27784D1563E5));
    expectEqual(@as(u64, 0x1313131313131313), desDecryptTest(0x1313131313131313, 0x2911CF5E94D33FE1));
    expectEqual(@as(u64, 0x1414141414141414), desDecryptTest(0x1414141414141414, 0x377B7F7CA3E5BBB3));
    expectEqual(@as(u64, 0x1515151515151515), desDecryptTest(0x1515151515151515, 0x701AA63832905A92));
    expectEqual(@as(u64, 0x1616161616161616), desDecryptTest(0x1616161616161616, 0x2006E716C4252D6D));
    expectEqual(@as(u64, 0x1717171717171717), desDecryptTest(0x1717171717171717, 0x452C1197422469F8));
    expectEqual(@as(u64, 0x1818181818181818), desDecryptTest(0x1818181818181818, 0xC33FD1EB49CB64DA));
    expectEqual(@as(u64, 0x1919191919191919), desDecryptTest(0x1919191919191919, 0x7572278F364EB50D));
    expectEqual(@as(u64, 0x1A1A1A1A1A1A1A1A), desDecryptTest(0x1A1A1A1A1A1A1A1A, 0x69E51488403EF4C3));
    expectEqual(@as(u64, 0x1B1B1B1B1B1B1B1B), desDecryptTest(0x1B1B1B1B1B1B1B1B, 0xFF847E0ADF192825));
    expectEqual(@as(u64, 0x1C1C1C1C1C1C1C1C), desDecryptTest(0x1C1C1C1C1C1C1C1C, 0x521B7FB3B41BB791));
    expectEqual(@as(u64, 0x1D1D1D1D1D1D1D1D), desDecryptTest(0x1D1D1D1D1D1D1D1D, 0x26059A6A0F3F6B35));
    expectEqual(@as(u64, 0x1E1E1E1E1E1E1E1E), desDecryptTest(0x1E1E1E1E1E1E1E1E, 0xF24A8D2231C77538));
    expectEqual(@as(u64, 0x1F1F1F1F1F1F1F1F), desDecryptTest(0x1F1F1F1F1F1F1F1F, 0x4FD96EC0D3304EF6));
}

fn tdesRoundsInt(comptime crypt_mode: des.CryptMode, keyLong: u192, dataLong: u64) u64 {
    const reversedKey = @byteSwap(u192, keyLong);
    const smallKey = mem.asBytes(&reversedKey).*;
    var key: [24]u8 = undefined;
    mem.copy(u8, &key, &smallKey);

    const reversedData = @byteSwap(u64, dataLong);
    const source = mem.asBytes(&reversedData);

    var dest: [8]u8 = undefined;
    var cipher = TDES.init(key);
    cipher.crypt(crypt_mode, &dest, source);
    return mem.readIntBig(u64, &dest);
}

fn tdesEncryptTest(keyLong: u192, dataLong: u64) u64 {
    return tdesRoundsInt(.Encrypt, keyLong, dataLong);
}

fn tdesDecryptTest(keyLong: u192, dataLong: u64) u64 {
    return tdesRoundsInt(.Decrypt, keyLong, dataLong);
}

// https://www.cosic.esat.kuleuven.be/nessie/testvectors/bc/des/Triple-Des-3-Key-192-64.unverified.test-vectors
test "TDES encrypt" {
    expectEqual(@as(u64, 0x95A8D72813DAA94D), tdesEncryptTest(0x800000000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0x0EEC1487DD8C26D5), tdesEncryptTest(0x400000000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0x7AD16FFB79C45926), tdesEncryptTest(0x200000000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0xD3746294CA6A6CF3), tdesEncryptTest(0x100000000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0x809F5F873C1FD761), tdesEncryptTest(0x080000000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0xC02FAFFEC989D1FC), tdesEncryptTest(0x040000000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0x4615AA1D33E72F10), tdesEncryptTest(0x020000000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0x8CA64DE9C1B123A7), tdesEncryptTest(0x010000000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0x2055123350C00858), tdesEncryptTest(0x008000000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0xDF3B99D6577397C8), tdesEncryptTest(0x004000000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0x31FE17369B5288C9), tdesEncryptTest(0x002000000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0xDFDD3CC64DAE1642), tdesEncryptTest(0x001000000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0x178C83CE2B399D94), tdesEncryptTest(0x000800000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0x50F636324A9B7F80), tdesEncryptTest(0x000400000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0xA8468EE3BC18F06D), tdesEncryptTest(0x000200000000000000000000000000000000000000000000, 0x0000000000000000));
    expectEqual(@as(u64, 0x8CA64DE9C1B123A7), tdesEncryptTest(0x000100000000000000000000000000000000000000000000, 0x0000000000000000));
}

test "TDES decrypt" {
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x800000000000000000000000000000000000000000000000, 0x95A8D72813DAA94D));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x400000000000000000000000000000000000000000000000, 0x0EEC1487DD8C26D5));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x200000000000000000000000000000000000000000000000, 0x7AD16FFB79C45926));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x100000000000000000000000000000000000000000000000, 0xD3746294CA6A6CF3));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x080000000000000000000000000000000000000000000000, 0x809F5F873C1FD761));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x040000000000000000000000000000000000000000000000, 0xC02FAFFEC989D1FC));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x020000000000000000000000000000000000000000000000, 0x4615AA1D33E72F10));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x010000000000000000000000000000000000000000000000, 0x8CA64DE9C1B123A7));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x008000000000000000000000000000000000000000000000, 0x2055123350C00858));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x004000000000000000000000000000000000000000000000, 0xDF3B99D6577397C8));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x002000000000000000000000000000000000000000000000, 0x31FE17369B5288C9));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x001000000000000000000000000000000000000000000000, 0xDFDD3CC64DAE1642));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x000800000000000000000000000000000000000000000000, 0x178C83CE2B399D94));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x000400000000000000000000000000000000000000000000, 0x50F636324A9B7F80));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x000200000000000000000000000000000000000000000000, 0xA8468EE3BC18F06D));
    expectEqual(@as(u64, 0x0000000000000000), tdesDecryptTest(0x000100000000000000000000000000000000000000000000, 0x8CA64DE9C1B123A7));
}

// Copied from std/crypto/test.zig cause I couldn't figure out how to import it
pub fn assertEqual(comptime expected: []const u8, input: []const u8) void {
    var expected_bytes: [expected.len / 2]u8 = undefined;
    for (expected_bytes) |*r, i| {
        r.* = fmt.parseInt(u8, expected[2 * i .. 2 * i + 2], 16) catch unreachable;
    }
    testing.expectEqualSlices(u8, &expected_bytes, input);
}

test "encrypt random data with ECB" {
    var keyLong: u64 = 0x133457799BBCDFF1;
    var keyBytes = mem.asBytes(&keyLong);
    mem.reverse(u8, keyBytes);
    const cipher = DES.init(keyBytes.*);

    var allocator = std.heap.page_allocator;
    const contents = try std.fs.cwd().readFileAlloc(allocator, "test/random_test_data_small.bin", 1000 * 1000 * 1000);
    defer allocator.free(contents);

    var encryptedData = try allocator.alloc(u8, contents.len);
    defer allocator.free(encryptedData);

    {
        var i: usize = 0;
        while (i < contents.len) : (i += des.block_size) {
            cipher.crypt(
                .Encrypt,
                encryptedData[i..(i + des.block_size)],
                contents[i..(i + des.block_size)]
            );
        }
    }

    var digest = Sha1.init();
    digest.update(encryptedData);
    var out: [Sha1.digest_length]u8 = undefined;
    digest.final(&out);

    assertEqual("9e250e46b4c79d5d09afb5a54635b7d43740dce5", &out);
}

test "decrypt random data with ECB" {
    var keyLong: u64 = 0x133457799BBCDFF1;
    var keyBytes = mem.asBytes(&keyLong);
    mem.reverse(u8, keyBytes);
    const cipher = DES.init(keyBytes.*);

    var allocator = std.heap.page_allocator;
    const contents = try std.fs.cwd().readFileAlloc(allocator, "test/random_test_data_small.bin", 1000 * 1000 * 1000);
    defer allocator.free(contents);

    var encryptedData = try allocator.alloc(u8, contents.len);
    {
        var i: usize = 0;
        while (i < contents.len) : (i += des.block_size) {
            cipher.crypt(
                .Encrypt,
                encryptedData[i..(i + des.block_size)],
                contents[i..(i + des.block_size)]
            );
        }
    }
    defer allocator.free(encryptedData);

    var decryptedData = try allocator.alloc(u8, contents.len);
    {
        var i: usize = 0;
        while (i < contents.len) : (i += des.block_size) {
            cipher.crypt(
                .Decrypt,
                decryptedData[i..(i + des.block_size)],
                encryptedData[i..(i + des.block_size)]
            );
        }
    }
    defer allocator.free(decryptedData);

    testing.expectEqualSlices(u8, contents, decryptedData);
}

test "3DES ECB crypt" {
    var allocator = std.heap.page_allocator;
    var inData = [_]u8{ 0, 0, 0, 0, 0, 0, 0, 0 };
    var encryptedData = try allocator.alloc(u8, inData.len);
    var decryptedData = try allocator.alloc(u8, inData.len);
    defer allocator.free(encryptedData);
    defer allocator.free(encryptedData);

    var key = [_]u8{0} ** 24;
    var cipher = TDES.init(key);
    var out = [_]u8{ 0x8C, 0xA6, 0x4D, 0xE9, 0xC1, 0xB1, 0x23, 0xA7 };
    cipher.crypt(.Encrypt, encryptedData, &inData);
    cipher.crypt(.Decrypt, decryptedData, encryptedData);
    testing.expectEqualSlices(u8, encryptedData, &out);
    testing.expectEqualSlices(u8, decryptedData, &inData);

    key = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 };
    cipher = TDES.init(key);
    out = [_]u8{ 0x89, 0x4B, 0xC3, 0x08, 0x54, 0x26, 0xA4, 0x41 };
    cipher.crypt(.Encrypt, encryptedData, &inData);
    cipher.crypt(.Decrypt, decryptedData, encryptedData);
    testing.expectEqualSlices(u8, encryptedData, &out);
    testing.expectEqualSlices(u8, decryptedData, &inData);

    key = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 };
    cipher = TDES.init(key);
    inData = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7 };
    out = [_]u8{ 0x58, 0xED, 0x24, 0x8F, 0x77, 0xF6, 0xB1, 0x9E };
    cipher.crypt(.Encrypt, encryptedData, &inData);
    cipher.crypt(.Decrypt, decryptedData, encryptedData);
    testing.expectEqualSlices(u8, encryptedData, &out);
    testing.expectEqualSlices(u8, decryptedData, &inData);
}
