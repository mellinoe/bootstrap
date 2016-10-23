#!/usr/bin/env bash
usage()
{
    echo "builds a bootstrap CLI from sources"
}

__build_arch=$(uname -p)
__build_os=$(uname -s)
__runtime_id=
__corelib=
__coreclrbin=
__configuration=debug
__crossgen=false

while [ "$1" != "" ]; do
        lowerI="$(echo $1 | awk '{print tolower($0)}')"
        case $lowerI in
        -h|--help)
            usage
            exit 1
            ;;
        --arch)
            shift
            __build_arch=$1
            ;;
        --rid)
            shift
            __runtime_id=$1
            ;;
        --os)
            shift
            __build_os=$1
            ;;
        debug)
            __configuration=debug
            ;;
        release)
            __configuration=release
            ;;
        --corelib)
            shift
            __corelib=$1
            ;;
        --skipcoresetup)
            __skipcoresetup=true
            ;;
        --skipcoreclr)
            __skipcoreclr=true
            ;;
        --skipcorefx)
            __skipcorefx=true
            ;;
        --skiplibuv)
            __skiplibuv=true
            ;;
        --coreclrbin)
            shift
            __coreclrbin=$1
            ;;
        --corefxbin)
            shift
            __corefxbin=$1
            ;;
        --crossgen)
            __crossgen=true
            ;;
         *)
        echo "Unknown argument to build.sh $1"; exit 1
    esac
    shift
done

mkdir -p dotnetcli
cp -r seed-cli/* dotnetcli

if [ "$__skipcoresetup" != "true" ]
    then
        echo "**** BUILDING CORE-SETUP NATIVE COMPONENTS ****"
        core-setup/src/corehost/build.sh --arch "$__build_arch" --rid "$__runtime_id" --hostver "1.0.2" --fxrver "1.0.2" --policyver "1.0.2" --commithash "b9b177468e9807e3b269bed630e310d5b8552fd8"
fi


if [ "$__skipcoreclr" != "true" ]
    then
        echo "**** BUILDING CORECLR NATIVE COMPONENTS ****"
        coreclr/build.sh $__configuration $__build_arch 2>&1 | tee coreclr.log
        export __coreclrbin=$(cat coreclr.log | sed -n -e 's/^.*Product binaries are available at //p')
        echo "CoreCLR binaries will be copied from $__coreclrbin"
fi

if [ "$__skipcorefx" != "true" ]
    then
        echo "**** BUILDING COREFX NATIVE COMPONENTS ****"
        corefx/src/Native/build-native.sh $__build_arch $__configuration $__build_os 2>&1 | tee corefx.log
        export __corefxbin=$(cat corefx.log | sed -n -e 's/^.*Build files have been written to: //p')
        echo "CoreFX binaries will be copied from $__corefxbin"
fi

if [ "$__skiplibuv" != "true" ]
    then
        echo "**** BUILDING LIBUV ****"
        ./build-libuv.sh
fi

echo "**** Copying binaries to dotnetcli/ ****"


if [ "$__coreclrbin" != "" ]
    then
        cp $__coreclrbin/*so dotnetcli/shared/Microsoft.NETCore.App/1.0.0
        cp $__coreclrbin/corerun dotnetcli/shared/Microsoft.NETCore.App/1.0.0
        cp $__coreclrbin/crossgen dotnetcli/shared/Microsoft.NETCore.App/1.0.0
else
    echo "CoreCLR binaries will not be copied. Specify coreclrbin or do not skip the coreclr build."
fi


cp cli/exe/dotnet dotnetcli
cp cli/exe/dotnet dotnetcli/shared/Microsoft.NETCore.App/1.0.0/corehost

cp cli/dll/libhostpolicy.so dotnetcli/shared/Microsoft.NETCore.App/1.0.0
cp cli/dll/libhostpolicy.so dotnetcli/sdk/1.0.0-preview3-003223

cp cli/fxr/libhostfxr.so dotnetcli/shared/Microsoft.NETCore.App/1.0.0
mkdir -p dotnetcli/host/fxr/1.0.1
cp cli/fxr/libhostfxr.so dotnetcli/host/fxr/1.0.1/
cp cli/fxr/libhostfxr.so dotnetcli/sdk/1.0.0-preview3-003223

if [ "$__corefxbin" != "" ]
    then
        cp $__corefxbin/**/System.* dotnetcli/shared/Microsoft.NETCore.App/1.0.0
else
    echo "CoreFX binaries will not be copied. Specify corefxbin or do not skip the corefx build."
fi

cp libuv/.libs/libuv.so dotnetcli/shared/Microsoft.NETCore.App/1.0.0

# COPY SYSTEM.PRIVATE.CORELIB.DLL FROM SOMEWHERE
if [ "$__corelib" != "" ]
    then
        cp "$__corelib" dotnetcli/shared/Microsoft.NETCore.App/1.0.0
fi

if [[ "$__corelib" != "" && "$__crossgen" == "true" ]]
    then
        dotnetcli/shared/Microsoft.NETCore.App/1.0.0/crossgen dotnetcli/shared/Microsoft.NETCore.App/1.0.0/System.Private.CoreLib.dll
fi

# Find/replace runtime ID in deps.json:
sed -i -- "s/ubuntu.16.04-x64/$__runtime_id/g" dotnetcli/shared/Microsoft.NETCore.App/1.0.0/Microsoft.NETCore.App.deps.json

# RUN STUFF

