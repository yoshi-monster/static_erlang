# Static Erlang

## What is this?

`static_erlang` is a statically-linked distribution of [Erlang/OTP](https://github.com/erlang/otp) for Linux with no external dependencies. This makes it extremely easy to install and distribute, especially when building releases.

## What is included?

`static_erlang` statically links with ncurses, OpenSSL and zlib. It makes most of OTP available, except for the following applications:

- `jinterface`
- `odbc`
- `wx` and dependents: `debugger` and `observer`. Note that `et` and `reltool` also come with modules that require `wx`; these will not work.

Header files are included as well because they are part of the final installation, but might be removed in the future as they serve no purpose.

Additionally, the Tarball also includes a prebuilt version of [rebar3](https://github.com/erlang/rebar3).

## What about NIFs?

Unfortunately, the way C programmers imagined the world left us with no proper way to dynamically load libraries from a static binary. Please either use a "full" Erlang installation, or find an alternative by using pure Erlang libraries or ports.

This also makes wxWidgets roughly impossible, but we could explore shipping a separate dynamic binary for `odbcserver` per architecture in the future.

There might be an interesting middle-ground here by "almost statically-linking" Erlang, which would only depend on a libc and the dynamic loader. A distribution like this would be less portable, but could potentially use odbc, and dynamic drivers and nifs.

## I really like the observer!

Use [spectator](https://hexdocs.pm/spectator/index.html) instead.
