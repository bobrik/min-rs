#![no_main]

#[no_mangle]
pub fn main() {
    hey_rs();
    hey_c();

    unsafe {
        libc::_exit(0);
    }
}

fn hey_rs() {
    // println!("hey from rust");
}

fn hey_c() {
    // unsafe {
    //     libc::syscall(
    //         libc::SYS_write,
    //         1,
    //         b"hey from libc\n\0" as *const u8 as *const libc::c_void,
    //         14,
    //     );
    // }
}
