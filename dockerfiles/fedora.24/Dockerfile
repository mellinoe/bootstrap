FROM fedora:24

RUN dnf install -y bash git cmake wget which python clang-3.8.0-2.fc24.x86_64 llvm-devel-3.8.0-1.fc24.x86_64 make libicu-devel lldb-devel.x86_64 \
                   libunwind-devel.x86_64 lttng-ust-devel.x86_64 uuid-devel libuuid-devel tar glibc-locale-source zlib-devel libcurl-devel \
                   krb5-devel openssl-devel autoconf libtool

RUN dnf upgrade -y nss
