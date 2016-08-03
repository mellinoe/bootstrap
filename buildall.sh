usage()
{
    echo "builds a bootstrap CLI from sources"
}

__buildArch=
__rid=
__corelib=

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
        *)
        echo "Unknown argument to build.sh $1"; exit 1
    esac
    shift
done

cp -r seed-cli dotnetcli

if [ "$__skipcoresetup" != "true" ]
    then
        echo **** BUILDING CORE-SETUP NATIVE COMPONENTS ****
        core-setup/src/corehost/build.sh --arch $__build_arch --rid $__runtime_id --hostver 1.0.2 --fxrver 1.0.2 --policyver 1.0.2 --commithash ff2908e099bbe6beac1f51afe37c9d176fb170e4
fi


if [ "$__skipcoreclr" != "true" ]
    then
        echo *** BUILDING CORECLR NATIVE COMPONENTS ****
        coreclr/build.sh
fi

if [ "$__skipcorefx" != "true" ]
    then
        if [ ! -f corefx/version.c ]
            then
                echo "static char sccsid[] __attribute__((used)) = \"@(#)No version information produced\";" > corefx/version.c
        fi

        corefx/src/Native/build-native.sh
fi

cp coreclr/bin/Product/Linux.x64.Debug/*so dotnetcli/shared/Microsoft.NETCore.App/1.0.0
cp coreclr/bin/Product/Linux.x64.Debug/corerun dotnetcli/shared/Microsoft.NETCore.App/1.0.0

cp cli/exe/dotnet dotnetcli

cp cli/dll/libhostpolicy.so dotnetcli/shared/Microsoft.NETCore.App/1.0.0
cp cli/dll/libhostpolicy.so dotnetcli/sdk/1.0.0-preview3-003223

cp cli/fxr/libhostfxr.so dotnetcli/shared/Microsoft.NETCore.App/1.0.0
cp cli/fxr/libhostfxr.so dotnetcli/host/fxr/1.0.1/
cp cli/fxr/libhostfxr.so dotnetcli/sdk/1.0.0-preview3-003223

cp corefx/Native/System.* dotnetcli/shared/Microsoft.NETCore.App/1.0.0

# COPY SYSTEM.PRIVATE.CORELIB.DLL FROM SOMEWHERE
if [ "$__corelib" != "" ]
    then
        cp "$__corelib" dotnetcli/shared/Microsoft.NETCore.App/1.0.0
fi

# RUN STUFF

