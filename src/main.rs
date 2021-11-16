#![feature(start)]
// #![feature(lang_items)]
#![no_std]

#[panic_handler]
fn panic_handler(_info: &::core::panic::PanicInfo) -> ! {
    loop {}
}

// #[lang = "eh_personality"]
// fn rust_eh_personality() {}

// #[lang = "eh_unwind_resume"]
// #[no_mangle]
// pub extern fn rust_eh_unwind_resume() {}

#[start]
fn main(argc: isize, argv: *const *const u8) -> isize {
    unsafe { ::libc::puts("Hello, world. From Rust.\0".as_ptr().cast()); }
    0
}

#[no_mangle]
extern "C" fn __uClibc_start_main(argc: isize, argv: *const *const u8) -> isize {
    unsafe { ::libc::exit(main(argc, argv) as _) }
}
