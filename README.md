# min-rs

A project showing how to build a minimal Rust executable.

## Why

You want to make a small executable, so you start from scratch:

```rust
pub fn main() {}
```

You build it:

```
$ cargo build --release
```

And it's gigantic:

```
$ ls -lh target/release/min-rs
-rwxr-xr-x 2 ivan dialout 3.6M Oct 22 02:15 target/release/min-rs
```

You look at elf section sizes and notice that there's a lot of debug info:

```
 size -A target/release/min-rs
target/release/min-rs  :
section                 size     addr
.interp                   27      624
.note.gnu.build-id        36      652
.note.ABI-tag             32      688
.gnu.hash                 28      720
.dynsym                 1704      752
.dynstr                 1049     2456
.gnu.version             142     3506
.gnu.version_r           176     3648
.rela.dyn              11448     3824
.rela.plt               1584    15272
.init                     20    16856
.plt                    1088    16880
.text                 188496    17968
.fini                     16   206464
.rodata                15549   206480
.eh_frame_hdr           3652   222032
.eh_frame              12752   225688
.gcc_except_table       2700   238440
.tbss                    120   309552
.init_array               16   309552
.fini_array                8   309568
.data.rel.ro            8624   309576
.dynamic                 544   318200
.got                     736   318744
.data                     88   319488
.bss                     560   319576
.comment                  39        0
.debug_aranges         37792        0
.debug_pubnames       405485        0
.debug_info           711829        0
.debug_abbrev           3082        0
.debug_line           430440        0
.debug_frame             200        0
.debug_str           1047736        0
.debug_pubtypes          162        0
.debug_ranges         750560        0
Total                3638520
```

You strip the binary, but it's still very large for an empty one:

```
$ ls -lh target/release/min-rs
-rwxr-xr-x 2 ivan dialout 251K Oct 22 02:16 target/release/min-rs
```

The `.text` section alone is huge:

```
.text                188496    17968
```

You arm yourself with [cargo-bloat](https://github.com/RazrFalcon/cargo-bloat):

```
cargo install cargo-bloat
```

```
$ cargo bloat --release
   Compiling min-rs v0.1.0 (/mnt/host/projects/min-rs)
    Finished release [optimized] target(s) in 0.23s
    Analyzing target/release/min-rs

File  .text     Size Crate Name
0.4%   8.2%  15.1KiB   std std::backtrace_rs::symbolize::gimli::resolve::{{closure}}
0.4%   8.1%  14.9KiB   std addr2line::ResDwarf<R>::parse
0.2%   4.2%   7.7KiB   std addr2line::ResUnit<R>::parse_lines
0.2%   3.8%   7.0KiB   std miniz_oxide::inflate::core::decompress
0.1%   2.1%   3.8KiB   std rustc_demangle::v0::Printer::print_type
0.1%   2.0%   3.7KiB   std gimli::read::unit::parse_attribute
0.1%   1.8%   3.2KiB   std rustc_demangle::demangle
0.1%   1.8%   3.2KiB   std <rustc_demangle::legacy::Demangle as core::fmt::Display>::fmt
0.1%   1.7%   3.1KiB   std addr2line::function::Function<R>::parse_children
0.1%   1.6%   3.0KiB   std gimli::read::rnglists::RngListIter<R>::next
0.1%   1.5%   2.8KiB   std rustc_demangle::v0::Printer::print_const
0.1%   1.5%   2.8KiB   std gimli::read::abbrev::Abbreviations::insert
0.1%   1.5%   2.7KiB   std std::backtrace_rs::symbolize::gimli::Context::new
0.1%   1.4%   2.5KiB   std core::slice::sort::recurse
0.1%   1.4%   2.5KiB   std rustc_demangle::v0::Printer::print_path
0.1%   1.3%   2.4KiB   std std::backtrace_rs::symbolize::gimli::elf::<impl std::backtrace_rs::symbolize::gimli::Mapping>::new_debug
0.1%   1.3%   2.3KiB   std gimli::read::unit::Attribute<R>::value
0.0%   0.9%   1.7KiB   std gimli::read::line::parse_attribute
0.0%   0.9%   1.7KiB   std <std::path::Components as core::iter::traits::iterator::Iterator>::next
0.0%   0.8%   1.5KiB   std std::backtrace_rs::symbolize::gimli::elf::Object::parse
2.6%  52.3%  96.3KiB       And 435 smaller methods. Use -n N to show more.
5.0% 100.0% 184.1KiB       .text section size, the file size is 3.6MiB
```

That's a lot of stuff you didn't ask for.

## How

First of all, the `backtrace` and `addr2line` stuff seems to be there
for unwinding on `panic!()`, so let's disable that in `Cargo.toml`:

```toml
[profile.release]
panic = "abort"
```

Still, there seems to be a lot of it there, you removed just under 2KiB:

```
$ cargo bloat --release
   Compiling min-rs v0.1.0 (/mnt/host/projects/min-rs)
    Finished release [optimized] target(s) in 0.23s
    Analyzing target/release/min-rs

File  .text     Size Crate Name
0.4%   8.3%  15.1KiB   std std::backtrace_rs::symbolize::gimli::resolve::{{closure}}
0.4%   8.2%  14.9KiB   std addr2line::ResDwarf<R>::parse
0.2%   4.2%   7.7KiB   std addr2line::ResUnit<R>::parse_lines
0.2%   3.8%   7.0KiB   std miniz_oxide::inflate::core::decompress
0.1%   2.1%   3.8KiB   std rustc_demangle::v0::Printer::print_type
0.1%   2.0%   3.7KiB   std gimli::read::unit::parse_attribute
0.1%   1.8%   3.2KiB   std rustc_demangle::demangle
0.1%   1.8%   3.2KiB   std <rustc_demangle::legacy::Demangle as core::fmt::Display>::fmt
0.1%   1.7%   3.1KiB   std addr2line::function::Function<R>::parse_children
0.1%   1.6%   3.0KiB   std gimli::read::rnglists::RngListIter<R>::next
0.1%   1.5%   2.8KiB   std rustc_demangle::v0::Printer::print_const
0.1%   1.5%   2.8KiB   std gimli::read::abbrev::Abbreviations::insert
0.1%   1.5%   2.7KiB   std std::backtrace_rs::symbolize::gimli::Context::new
0.1%   1.4%   2.5KiB   std core::slice::sort::recurse
0.1%   1.4%   2.5KiB   std rustc_demangle::v0::Printer::print_path
0.1%   1.3%   2.4KiB   std std::backtrace_rs::symbolize::gimli::elf::<impl std::backtrace_rs::symbolize::gimli::Mapping>::new_debug
0.1%   1.3%   2.3KiB   std gimli::read::unit::Attribute<R>::value
0.0%   0.9%   1.7KiB   std gimli::read::line::parse_attribute
0.0%   0.9%   1.7KiB   std <std::path::Components as core::iter::traits::iterator::Iterator>::next
0.0%   0.8%   1.5KiB   std std::backtrace_rs::symbolize::gimli::elf::Object::parse
2.6%  51.9%  94.6KiB       And 424 smaller methods. Use -n N to show more.
5.0% 100.0% 182.3KiB       .text section size, the file size is 3.6MiB
```

Let's also enable LTO to let the linker remove things we don't need,
byt adding the following under `[profile.release]` in `Cargo.toml`:

```toml
lto = true
```

That's much better, but still a lot left:

```
$ cargo bloat --release
   Compiling min-rs v0.1.0 (/mnt/host/projects/min-rs)
    Finished release [optimized] target(s) in 2.30s
    Analyzing target/release/min-rs

 File  .text     Size     Crate Name
 1.3%  11.3%  18.8KiB       std addr2line::ResDwarf<R>::parse
 1.1%   9.2%  15.4KiB       std std::backtrace_rs::symbolize::gimli::resolve::{{closure}}
 0.6%   5.0%   8.3KiB       std addr2line::ResUnit<R>::parse_lines
 0.5%   4.3%   7.1KiB       std miniz_oxide::inflate::core::decompress
 0.3%   2.6%   4.4KiB       std rustc_demangle::v0::Printer::print_type
 0.3%   2.2%   3.7KiB       std gimli::read::unit::parse_attribute
 0.2%   2.1%   3.5KiB       std <&T as core::fmt::Display>::fmt
 0.2%   2.1%   3.5KiB       std rustc_demangle::v0::Printer::print_const
 0.2%   1.9%   3.1KiB       std rustc_demangle::try_demangle
 0.2%   1.9%   3.1KiB       std rustc_demangle::v0::Printer::print_path
 0.2%   1.8%   3.1KiB       std addr2line::function::Function<R>::parse_children
 0.2%   1.7%   2.8KiB       std gimli::read::rnglists::RngListIter<R>::next
 0.2%   1.5%   2.6KiB       std std::backtrace_rs::symbolize::gimli::elf::<impl std::backtrace_rs::symbolize::gimli::Mapping>::new_debug
 0.2%   1.5%   2.5KiB       std std::panicking::rust_panic_with_hook
 0.2%   1.5%   2.5KiB       std core::slice::sort::recurse
 0.2%   1.5%   2.4KiB       std std::backtrace_rs::symbolize::gimli::Context::new
 0.2%   1.4%   2.3KiB       std gimli::read::unit::Attribute<R>::value
 0.1%   1.0%   1.7KiB       std gimli::read::line::parse_attribute
 0.1%   1.0%   1.7KiB       std <std::path::Components as core::iter::traits::iterator::Iterator>::next
 0.1%   0.9%   1.5KiB [Unknown] main
 4.9%  43.4%  72.4KiB           And 221 smaller methods. Use -n N to show more.
11.4% 100.0% 166.8KiB           .text section size, the file size is 1.4MiB
```

It turns out, the rust standard library is compiled with fancy aborts, so to
remove those you need to recompile it with the `panic_immediate_abort` feature.
You can do it with [xargo](https://github.com/japaric/xargo), but you also
need nightly Rust to recompile the standard library. Let's install it:

```
$ cargo install xargo
$ rustup toolchain install nightly
$ rustup run nightly rustup component add rust-src
```

And put the following in `Xargo.toml`:

```
[dependencies]
std = { default-features = false, features = ["panic_immediate_abort"] }
```

Note that I'm passing `--target aarch64-unknown-linux-gnu` to `xargo`, that's
because I'm running on arm64 Linux and xargo requires an explicit target:

* https://github.com/japaric/xargo/issues/209

You might be on a different architecture and need to adjust the flag.

Run it and you'll see a 10x reduction in `.text` size:

```
$ rustup run nightly xargo bloat --release --target aarch64-unknown-linux-gnu
    Finished release [optimized] target(s) in 0.01s
    Analyzing target/aarch64-unknown-linux-gnu/release/min-rs

 File  .text    Size     Crate Name
 3.7%  10.5%  1.7KiB [Unknown] main
 3.2%   9.2%  1.5KiB       std std::sync::once::Once::call_inner
 2.2%   6.4%  1.0KiB       std core::fmt::Formatter::pad
 1.5%   4.3%    732B       std std::sys::unix::stack_overflow::imp::signal_handler
 1.4%   4.0%    668B       std <core::fmt::builders::PadAdapter as core::fmt::Write>::write_str
 1.3%   3.8%    644B       std core::fmt::Formatter::pad_integral
 1.2%   3.5%    588B       std core::fmt::write
 1.1%   3.3%    548B       std <&T as core::fmt::Debug>::fmt
 1.1%   3.2%    540B       std <&T as core::fmt::Debug>::fmt
 1.0%   2.8%    476B       std <&mut W as core::fmt::Write>::write_char
 1.0%   2.8%    476B       std core::fmt::Write::write_char
 0.9%   2.7%    448B       std <core::result::Result<T,E> as core::fmt::Debug>::fmt
 0.9%   2.4%    412B       std std::io::stdio::cleanup
 0.8%   2.4%    400B       std <&T as core::fmt::Debug>::fmt
 0.7%   2.1%    360B       std std::thread::current
 0.7%   2.0%    332B       std core::fmt::builders::DebugTuple::field
 0.7%   1.9%    328B       std std::sys::unix::decode_error_kind
 0.7%   1.9%    320B       std alloc::raw_vec::finish_grow
 0.7%   1.9%    320B       std core::fmt::num::imp::<impl core::fmt::Display for u64>::fmt
 0.6%   1.8%    304B       std <std::io::Write::write_fmt::Adapter<T> as core::fmt::Write>::write_str
 8.8%  25.2%  4.1KiB           And 49 smaller methods. Use -n N to show more.
34.9% 100.0% 16.4KiB           .text section size, the file size is 47.1KiB
```

Still there's this remaining stuff we didn't ask for. You can get rid of it:

```rust
#![no_main]

#[no_mangle]
pub fn main() {}
```

With this you're down to just 420B of `.text`:

```
$ rustup run nightly xargo bloat --release --target aarch64-unknown-linux-gnu
   Compiling min-rs v0.1.0 (/mnt/host/projects/min-rs)
    Finished release [optimized] target(s) in 0.62s
    Analyzing target/aarch64-unknown-linux-gnu/release/min-rs

File  .text Size     Crate Name
1.3%  29.5% 124B [Unknown] __libc_csu_init
0.2%   4.8%  20B [Unknown] call_weak_fn
0.0%   1.0%   4B [Unknown] __libc_csu_fini
0.0%   1.0%   4B       std std::sys::unix::args::imp::ARGV_INIT_ARRAY::init_wrapper
0.0%   1.0%   4B       std rust_eh_personality
0.0%   0.0%   0B           And 0 smaller methods. Use -n N to show more.
4.6% 100.0% 420B           .text section size, the file size is 9.0KiB
```

Unfortunately, the code doesn't run too good and exits:

```
$ ./target/aarch64-unknown-linux-gnu/release/min-rs; echo $?
1
```

That's because before Rust was responsible for `main`, but with `#![no_main]`
it's up to you to deal with all of it. Setting exit code can be done with `libc`
crate, if you add it to dependencies in `Cargo.toml`:

```toml
[dependencies]
libc = { version = "0.2", default-features = false }
```

Then add the following into `fn main()`:

```rust
    unsafe {
        libc::_exit(0);
    }
```

That adds 6 bytes to the binary:

```
$ rustup run nightly xargo bloat --release --target aarch64-unknown-linux-gnu
   Compiling min-rs v0.1.0 (/mnt/host/projects/min-rs)
    Finished release [optimized] target(s) in 0.64s
    Analyzing target/aarch64-unknown-linux-gnu/release/min-rs

File  .text Size     Crate Name
1.3%  28.4% 124B [Unknown] __libc_csu_init
0.2%   4.6%  20B [Unknown] call_weak_fn
0.1%   2.8%  12B [Unknown] main
0.0%   0.9%   4B [Unknown] __libc_csu_fini
0.0%   0.9%   4B       std std::sys::unix::args::imp::ARGV_INIT_ARRAY::init_wrapper
0.0%   0.0%   0B           And 0 smaller methods. Use -n N to show more.
4.7% 100.0% 436B           .text section size, the file size is 9.0KiB
```

And it exits successfully now:

```
$ ./target/aarch64-unknown-linux-gnu/release/min-rs; echo $?
0
```

Adding a simple greeting to the code:

```rust
println!("hey from rust");
```

Will cost you 10KiB:

```
$ rustup run nightly xargo bloat --release --target aarch64-unknown-linux-gnu
   Compiling min-rs v0.1.0 (/mnt/host/projects/min-rs)
    Finished release [optimized] target(s) in 0.70s
    Analyzing target/aarch64-unknown-linux-gnu/release/min-rs

 File  .text    Size Crate Name
 3.7%  12.6%  1.3KiB   std std::sync::once::Once::call_inner
 2.2%   7.4%    784B   std <std::io::Write::write_fmt::Adapter<T> as core::fmt::Write>::write_str
 1.8%   6.1%    644B   std core::fmt::Formatter::pad_integral
 1.6%   5.5%    588B   std core::fmt::write
 1.3%   4.5%    476B   std <&mut W as core::fmt::Write>::write_char
 1.3%   4.5%    476B   std core::fmt::Write::write_char
 1.1%   3.6%    380B   std std::io::buffered::bufwriter::BufWriter<W>::write_all_cold
 1.0%   3.2%    344B   std std::io::buffered::bufwriter::BufWriter<W>::flush_buf
 0.9%   3.1%    328B   std std::sys::unix::decode_error_kind
 0.9%   3.0%    320B   std alloc::raw_vec::finish_grow
 0.9%   3.0%    320B   std core::fmt::num::imp::<impl core::fmt::Display for u64>::fmt
 0.8%   2.9%    304B   std <std::io::Write::write_fmt::Adapter<T> as core::fmt::Write>::write_str
 0.8%   2.9%    304B   std <&mut W as core::fmt::Write>::write_str
 0.7%   2.5%    264B   std std::io::Write::write_fmt
 0.7%   2.5%    264B   std std::io::stdio::_print
 0.7%   2.5%    260B   std std::alloc::default_alloc_error_hook
 0.7%   2.5%    260B   std std::sys_common::thread_local_key::StaticKey::lazy_init
 0.7%   2.5%    260B   std std::sys_common::thread_local_dtor::register_dtor_fallback
 0.6%   2.2%    228B   std <&mut W as core::fmt::Write>::write_char
 0.6%   2.1%    224B   std core::fmt::Write::write_char
 5.3%  18.0%  1.9KiB       And 38 smaller methods. Use -n N to show more.
29.3% 100.0% 10.4KiB       .text section size, the file size is 35.3KiB
```

You can instead doit via `libc`:

```rust
unsafe {
    libc::syscall(
        libc::SYS_write,
        1,
        b"hey from libc\n\0" as *const u8 as *const libc::c_void,
        14,
    );
}
```

And it will be a lot less machine code:

```
$ rustup run nightly xargo bloat --release --target aarch64-unknown-linux-gnu
    Finished release [optimized] target(s) in 0.01s
    Analyzing target/aarch64-unknown-linux-gnu/release/min-rs

File  .text Size     Crate Name
1.3%  27.4% 124B [Unknown] __libc_csu_init
0.4%   8.8%  40B [Unknown] main
0.2%   4.4%  20B [Unknown] call_weak_fn
0.0%   0.9%   4B [Unknown] __libc_csu_fini
0.0%   0.9%   4B       std std::sys::unix::args::imp::ARGV_INIT_ARRAY::init_wrapper
0.0%   0.0%   0B           And 0 smaller methods. Use -n N to show more.
4.8% 100.0% 452B           .text section size, the file size is 9.2KiB
```

Note that this part is specific to Linux and won't work on macOS.

## Building this project

* Run `make deps` to install the dependencies.
* Run `make build` to build a binary.
* Run `make run` to run the binary (re-building if needed).
* Run `make bloat` to see the `cargo-bloat` report.

Note that the `release` profile we use has debug symbols disabled.
